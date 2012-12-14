/*
 * Copyright © 2007 All Rights Reserved.
 */

#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <linux/soundcard.h>
#include <math.h>
#include <sys/wait.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#define SRATE 8000

#define BEEPTYPE_CONSOLE	1
#define BEEPTYPE_DSP		2
#define BEEPTYPE_CIT		3

struct beep {
	char *dev;
	int type;
	int fd_client;
	int fd_dev;
	int pid;
};


struct beepmsg {
	double freq;
	double duration;
	double volume;
};


 
 
struct cit_beep_param { 
	int iFrequency; 
	int iBepTime; // duration, unit: ms 
	int iVlmStep; // volume, 5 levels 
};

 
#define BEEP_IOC_MAGIC 'N' 
#define BEEP_IOCS _IOW(BEEP_IOC_MAGIC, 1, int) 
#define BEEP_IOCG _IOR(BEEP_IOC_MAGIC, 2, int) 
#define BEEP_BEEP _IO(BEEP_IOC_MAGIC, 3) 


static void bip_cit(struct beep *beep, double freq, double duration, double volume)
{
	struct cit_beep_param bp;
	int r;

	bp.iFrequency = freq;
	bp.iBepTime = duration * 1000;
	bp.iVlmStep = volume * 5;
	r = ioctl(beep->fd_dev, BEEP_IOCS, &bp);
	if(r != 0) perror("ioctl(BEEP_IOCS)");
	ioctl(beep->fd_dev, BEEP_BEEP, &bp);
	if(r != 0) perror("ioctl(BEEP_BEEP)");
}


static void bip_console(struct beep *beep, double freq, double duration, double volume)
{
	char buf[32];
	int l;

	l = snprintf(buf, sizeof(buf), "\e[10;%.0f]\e[11;%.0f]\x7", freq, duration * 1000);
	if(write(beep->fd_dev, buf, l)) {}
	usleep(duration * 1E6);
}


static void bip_dsp(struct beep *beep, double freq, double duration, double volume)
{
	unsigned char buf[SRATE];
	double t = 0;
	int i;
	int frag = 0x00040004;

	if(duration > 1.0) duration = 1.0;

	for(i=0; i<duration*SRATE; i++) {
		buf[i] = sin(t * freq * M_PI * 2) * volume * 120 + 127;
		t += 1.0 / SRATE;
	}

	ioctl(beep->fd_dev, SNDCTL_DSP_SETFRAGMENT, &frag);
	if(write(beep->fd_dev, buf, i)) {}
}


static void beep_client(struct beep *beep)
{
	struct beepmsg beepmsg;
	int l;

	while(1) {
		l = read(beep->fd_client, &beepmsg, sizeof(beepmsg));
		if(l <= 0) return;

		if(beep->type == BEEPTYPE_CONSOLE)  bip_console(beep, beepmsg.freq, beepmsg.duration, beepmsg.volume);
		if(beep->type == BEEPTYPE_DSP) bip_dsp(beep, beepmsg.freq, beepmsg.duration, beepmsg.volume);
		if(beep->type == BEEPTYPE_CIT) bip_cit(beep, beepmsg.freq, beepmsg.duration, beepmsg.volume);
	}
}


static int l_new(lua_State *L)
{
	struct beep *beep;
	int fd[2];
	const char *dev;
	int i;

	dev = luaL_checkstring(L, 1);

	if(pipe(fd)) {}

	beep = lua_newuserdata(L, sizeof *beep);
	if(beep == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, "Not enough memory");
		return 2;
	}
	luaL_getmetatable(L, "beepthread");
	lua_setmetatable(L, -2);

	beep->dev = strdup(dev);
	beep->fd_dev = open(dev, O_WRONLY);
	if(beep->fd_dev == -1) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
	beep->type = strstr(dev, "dsp") ? BEEPTYPE_DSP : BEEPTYPE_CONSOLE;
	beep->type = strstr(dev, "beeper") ? BEEPTYPE_CIT : beep->type;

	beep->pid = fork();

	if (beep->pid == 0) {
		for(i=3; i<64; i++) if(i != fd[0] && i != beep->fd_dev) close(i);
		beep->fd_client = fd[0];
		close(fd[1]);
		beep_client(beep);
		_exit(0);
	} else {
		beep->fd_client = fd[1];
		close(fd[0]);
	}

	return 1;
}


static int l_beep(lua_State *L)
{
	struct beep *beep;
	struct beepmsg beepmsg;

	beep = lua_touserdata(L, 1);
	beepmsg.freq = luaL_checknumber(L, 2);
	beepmsg.duration = luaL_checknumber(L, 3);
	beepmsg.volume = luaL_optnumber(L, 4, 1.0);

	if(write(beep->fd_client, &beepmsg, sizeof(beepmsg))) {}

	return 0;
}


static int l_free(lua_State *L)
{
	struct beep *beep;
	int status;

	beep = lua_touserdata(L, 1);
	if(beep->dev) { free(beep->dev); beep->dev=0; }
	close(beep->fd_client);
	close(beep->fd_dev);
	kill(beep->pid, SIGTERM);
	waitpid(beep->pid, &status, 0);

	return 0;
}


static struct luaL_Reg beepthread_table[] = {
	{ "new",	l_new },
	{ "__gc",	l_free },
	{ NULL },
};


static struct luaL_Reg beepthread_metatable[] = {
	{ "beep",	l_beep },
	{ "free",	l_free },
	{ NULL },
};


int luaopen_beepthread(lua_State *L)
{
	luaL_newmetatable(L, "beepthread"); 
	lua_pushstring(L, "__index");
	lua_pushvalue(L, -2); 
	lua_settable(L, -3); 

	luaL_register(L, NULL, beepthread_metatable);
	luaL_register(L, "beepthread", beepthread_table);

	return 1;             
}

