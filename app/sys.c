/*
 * Copyright © 2007 All Rights Reserved.
 */

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <sys/select.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <termios.h>
#include <unistd.h>
#include <sys/socket.h>
#include <syslog.h>
#include <signal.h>
#include <linux/input.h>
#include <dirent.h>
#include <pty.h>
#include <malloc.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

//#define TRACE(msg...) { fprintf(stderr,"%s:%d - %s ", __FILE__, __LINE__, __FUNCTION__);fprintf(stderr,msg);fprintf(stderr,"\n"); }
#define TRACE(msg...) {}


/**************************************************************************
* Generic handler catching all signals
**************************************************************************/

static const char const *signame[] = {
	[0] = "",
	[SIGHUP] = "SIGHUP",
	[SIGINT] = "SIGINT",
	[SIGQUIT] = "SIGQUIT",
	[SIGILL] = "SIGILL",
	[SIGTRAP] = "SIGTRAP",
	[SIGABRT] = "SIGABRT",
	[SIGIOT] = "SIGIOT",
	[SIGBUS] = "SIGBUS",
	[SIGFPE] = "SIGFPE",
	[SIGKILL] = "SIGKILL",
	[SIGUSR1] = "SIGUSR1",
	[SIGSEGV] = "SIGSEGV",
	[SIGUSR2] = "SIGUSR2",
	[SIGPIPE] = "SIGPIPE",
	[SIGALRM] = "SIGALRM",
	[SIGTERM] = "SIGTERM",
	[SIGSTKFLT] = "SIGSTKFLT",
	[SIGCHLD] = "SIGCHLD",
	[SIGCONT] = "SIGCONT",
	[SIGSTOP] = "SIGSTOP",
	[SIGTSTP] = "SIGTSTP",
	[SIGTTIN] = "SIGTTIN",
	[SIGTTOU] = "SIGTTOU",
	[SIGURG] = "SIGURG",
	[SIGXCPU] = "SIGXCPU",
	[SIGXFSZ] = "SIGXFSZ",
	[SIGVTALRM] = "SIGVTALRM",
	[SIGPROF] = "SIGPROF",
	[SIGWINCH] = "SIGWINCH",
	[SIGIO] = "SIGIO",
	[SIGPWR] = "SIGPWR",
	[SIGSYS] = "SIGSYS",
	NULL
};

#define SIGQ_SIZE 64

static int signal_fd = -1;

static void signal_handler(int signo)
{
	char buf[16];
	int r;

	if(signal_fd != -1) {
		snprintf(buf, sizeof(buf), "%s\n", signame[signo]);
		r = write(signal_fd, buf, strlen(buf));
	}
}

/**************************************************************************
* Lua wrappers for various system functions not avaialble in the Lua
* language
**************************************************************************/

static int l_version(lua_State *L)
{
	// watch out: without cast to const char* it compiles but lua_pushstring does not work correct
	lua_pushstring(L, (const char*)VERSION);
	lua_pushstring(L, (const char*)BUILD );
	lua_pushstring(L, (const char*)__DATE__);
	return 3;
}


static int l_meminfo(lua_State *L)
{
	struct mallinfo mi;

	mi = mallinfo();

	lua_pushnumber(L, mi.arena);
	return 1;
}

/*
 * Takes and returns a table like { r = { <fd>=true, <fd>=true}, w = { <fd> = true }, e = { <fd> = true }}
 */

static int l_select(lua_State *L)
{
	const char *what[] = { "r", "w", "e" };
	fd_set fds[3];	/* read, write, error */
	struct timeval tv;
	double timeout;
	int fd;
	int fd_max = 0;
	int r;
	int have_timeout = 0;
	int i;

	/* Get fd's from tables */
		
	if(!lua_istable(L, 1)) return 0;

	for(i=0; i<3; i++) {
		lua_getfield(L, 1, what[i]);
		if(!lua_istable(L, -1)) return 0;

		FD_ZERO(&fds[i]);
		lua_pushnil(L);
		while (lua_next(L, -2) != 0) {
			fd = lua_tonumber(L, -2);
			FD_SET(fd, &fds[i]);
			if(fd > fd_max) fd_max = fd;
			lua_pop(L, 1);
		}

		lua_pop(L, 1);
	}


	/* Get timeout */

	if(lua_isnumber(L, 2)) {
		timeout = lua_tonumber(L, 2);
		have_timeout = 1;
		tv.tv_sec  = timeout;
		tv.tv_usec = (timeout - tv.tv_sec) * 1E6;
	}

	
	r = select(fd_max+1, &fds[0], &fds[1], &fds[2], have_timeout ? &tv : NULL);

	if(r <= 0) return 0;	/* timeout or signaled */

	/* Return table with all fd's that have data ready per 'what' (r, w, e) */
		
	lua_newtable(L);

	for(i=0; i<3; i++) {
		lua_newtable(L);
		for(fd=1; fd<=fd_max; fd++) {
			if(FD_ISSET(fd, &fds[i])) {
				lua_pushnumber(L, fd);
				lua_pushboolean(L, 1);
				lua_settable(L, -3);
			}
		}
		lua_setfield(L, -2, what[i]);
	}

	return 1;
}


static int l_hirestime(lua_State *L)
{
	struct timespec tv;
	double now;

	clock_gettime(CLOCK_MONOTONIC, &tv);

	now = tv.tv_sec + (tv.tv_nsec) / 1.0E9;
	lua_pushnumber(L, now);
	return 1;
}


static int l_sleep(lua_State *L)
{
	double t = luaL_checknumber(L, 1);

	usleep(t * 1.0E6);
	return 0;
}


static int l_macaddr(lua_State *L)
{
	int fd;
	struct ifreq ifr;
	const char *ifname;
	struct sockaddr_in *sa;
	int r;
	char buf[256];
	char a[32];

	ifname = luaL_checkstring(L, 1);

	fd = socket(PF_INET, SOCK_DGRAM, 0);

        memset(&ifr, 0, sizeof(ifr));
	strncpy(ifr.ifr_name, ifname, sizeof(ifr.ifr_name));

	sa = (struct sockaddr_in *)&(ifr.ifr_addr);
	sa->sin_family = AF_INET;
	
	/* Get MAC address */
	
	r = ioctl(fd, SIOCGIFHWADDR, &ifr);
	if(r == 0) {
		memcpy(a, ifr.ifr_hwaddr.sa_data, 6);
		snprintf(buf, sizeof(buf), "%02x:%02x:%02x:%02x:%02x:%02x",
			(unsigned char)ifr.ifr_hwaddr.sa_data[0],
			(unsigned char)ifr.ifr_hwaddr.sa_data[1],
			(unsigned char)ifr.ifr_hwaddr.sa_data[2],
			(unsigned char)ifr.ifr_hwaddr.sa_data[3],
			(unsigned char)ifr.ifr_hwaddr.sa_data[4],
			(unsigned char)ifr.ifr_hwaddr.sa_data[5]);
	} else {
		snprintf(buf, sizeof(buf), "??:??:??:??:??:??");
	}

	close(fd);

	lua_pushstring(L, buf);
	return 1;

}



static int l_open(lua_State *L)
{
	const char *fname;
	const char *mode;
	int fd;
	int m = 0;

	fname = luaL_checkstring(L, 1);
	mode = luaL_checkstring(L, 2);

	if(strcmp(mode, "r") == 0) m = O_RDONLY;
	if(strcmp(mode, "w") == 0) m = O_WRONLY;
	if(strcmp(mode, "rw") == 0) m = O_RDWR;

	fd = open(fname, m | O_NDELAY);

	if(fd == -1) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushinteger(L, fd);
	return 1;
}


static int l_close(lua_State *L)
{
	int fd;
	int r;

	fd = luaL_checknumber(L, 1);
	r = close(fd);
	lua_pushinteger(L, r);
	return 0;
}


static int l_pipe(lua_State *L)
{
	int fd[2];
	int r;
	int flags;
	
	r = pipe(fd);

	if(r == 0) {

		flags = fcntl(fd[0], F_GETFL);
		flags |= O_NONBLOCK;
		fcntl(fd[0], F_SETFL, flags);

		lua_pushnumber(L, fd[0]);
		lua_pushnumber(L, fd[1]);
	} else {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
	}
	return 2;
}

/* read charracters from file without actualy waiting for the answer
 * 
 * @param l[1]    filedescriptor prev opened with l_open()
 * @param len     number of chars to be read
 * @return <data>|nil, errorstr
 */
static int l_read(lua_State *L)
{
	int fd = luaL_checknumber(L, 1);
	size_t len = luaL_checknumber(L, 2);

	char *buf = malloc(len);
	memset(buf,0,len);
	if(!buf) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	size_t len2 = read(fd, buf, len);
	if(len2 == -1) {
		TRACE("fd=%d buflen=%d errno=%d", fd, len2, errno)
		if(errno != EAGAIN) {
			free(buf);
			lua_pushnil(L);
			lua_pushstring(L, strerror(errno));
			return 2;
		} else {
			free(buf);
			lua_pushstring(L, "");
			return 1;
		}
	}

	if(len2>0)
		TRACE("fd=%d buflen=%d", fd, len2)
	lua_pushlstring(L, buf, len2);
	free(buf);
	return 1;
}

static int l_tcflush(lua_State *L)
{
	int fd = luaL_checknumber(L, 1);
	tcflush(fd,TCIOFLUSH);
	return 0;
}

// implement a sequential read with a timeout on received data
static int l_readport(lua_State *L)
{
	int no=0;
	int rc;
	struct timeval tv;

	int fd = luaL_checknumber(L, 1);
	size_t len = luaL_checknumber(L, 2);
	int maxwaittime = luaL_checknumber(L, 3);

	fd_set readfd;
	tv.tv_sec=maxwaittime/1000;    //SECOND
	tv.tv_usec=maxwaittime%1000*1000; //USECOND
	FD_ZERO(&readfd);
	FD_SET(fd,&readfd);
	char *buf = malloc(len+1);
	memset(buf,0,len+1);
	rc=select(fd+1,&readfd,NULL,NULL,&tv);

	if(rc>0)
	{
		//tv.tv_sec=0;  // SECOND
		//tv.tv_usec=50000; // USECOND
		
		do
		{
			rc = read(fd,&buf[no],1);
			no += 1;
			rc=select(fd+1,&readfd,NULL,NULL,&tv);
		}
		while(rc>0 && no<len);

		if(no>0)
		{
			TRACE("fd=%d buflen=%d", fd, no)
			lua_pushlstring(L, buf, no);
			free(buf);
			return 1;
		}
	}
	return 0;	
}



static int l_write(lua_State *L)
{
	int fd;
	const char *buf;
	size_t len;
	int r;

	fd = luaL_checknumber(L, 1);
	buf = luaL_checklstring(L, 2, &len);
	TRACE("len=%d, buff=%s", len,buf)
	r = write(fd, buf, len);

	if(r >= 0) {
		lua_pushnumber(L, r);
		return 1;
	} else {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	} 
}


static int l_fork(lua_State *L)
{
	int pid = fork();
	if(pid != -1) {
		lua_pushnumber(L, pid);
		return 1;
	} else {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
}


static int l_dup2(lua_State *L)
{
	int fd_from;
	int fd_to;
	int r;

	fd_from = lua_tonumber(L, 1);
	fd_to = lua_tonumber(L, 2);
	r = dup2(fd_from, fd_to);

	if(r == 0) {
		lua_pushboolean(L, 1);
		return 1;
	} else {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
}


static int l_set_noncanonical(lua_State *L)
{
	int fd = luaL_checknumber(L, 1);
	int set = lua_toboolean(L, 2);
	struct termios tios;
	static struct termios save[32];
	int r;

	if(set) {
		tcgetattr(fd, &save[fd]);
		tcgetattr(fd, &tios);

		tios.c_lflag     = 0;
		tios.c_cc[VTIME] = 0;
		tios.c_cc[VMIN]  = 1;

		tcflush (fd, TCIFLUSH);
		r = tcsetattr (fd, TCSANOW, &tios);
	} else {
		r = tcsetattr (fd, TCSANOW, &save[fd]);
	}
		
	if(r == 0) {
		lua_pushboolean(L, 1);
		return(1);
	} else {
		lua_pushboolean(L, 0);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
}


static int l_set_baudrate(lua_State *L)
{
	int fd = luaL_checknumber(L, 1);
	int baudrate = luaL_checknumber(L, 2);
	struct termios tios;
	int br;
	int rtscts = 0;
	int r;
		
	switch(baudrate) {
		case   300:	br =  B300;   break;
		case  1200:	br =  B1200;  break;
		case  2400: 	br =  B2400;  break;
		case  4800:	br =  B4800;  break;
		case  9600:	br =  B9600;  break;
		case 19200:	br =  B19200; break;
		case 38400:	br =  B38400; break;
		case 57600:	br =  B57600; break;
		default:	br = B115200; break;
	}

	tios.c_cflag = br | CS8 | CLOCAL | CREAD;  
	if(rtscts) tios.c_cflag |= CRTSCTS; 
	tios.c_iflag = IGNPAR;
	tios.c_oflag = OPOST;

	tcflush (fd, TCIFLUSH);
	r = tcsetattr (fd, TCSANOW, &tios);
	if(r == 0) {
		lua_pushboolean(L, 1);
		return 1;
	} else {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	return 0;
}


static int l_daemonize(lua_State *L)
{
	setsid();
	if(fork()) exit(0);
	if(fork()) exit(0);
	close(1);
	close(2);
	return 0;
}


static int l_syslog(lua_State *L)
{
	int prio;
	const char *msg;

	prio = lua_tonumber(L, 1);
	msg = luaL_checkstring(L, 2);

	syslog(prio, "%s", msg);
	
	return 0;
}


static int l_isatty(lua_State *L)
{
	lua_pushboolean(L, isatty(1));
	return 1;
}


static int l_lstat(lua_State *L)
{
	struct stat s;
	const char *fname;
	int r;

	fname = luaL_checkstring(L, 1);
	r = lstat(fname, &s);

	if(r == 0) {
		lua_newtable(L);
		lua_pushstring(L, "dev"); lua_pushnumber(L, s.st_dev); lua_settable(L, -3);
		lua_pushstring(L, "ino"); lua_pushnumber(L, s.st_ino); lua_settable(L, -3);
		lua_pushstring(L, "mode"); lua_pushnumber(L, s.st_mode); lua_settable(L, -3);
		lua_pushstring(L, "size"); lua_pushnumber(L, s.st_size); lua_settable(L, -3);
		lua_pushstring(L, "atime"); lua_pushnumber(L, s.st_atime); lua_settable(L, -3);
		lua_pushstring(L, "mtime"); lua_pushnumber(L, s.st_mtime); lua_settable(L, -3);
		lua_pushstring(L, "ctime"); lua_pushnumber(L, s.st_ctime); lua_settable(L, -3);
		lua_pushstring(L, "isreg"); lua_pushboolean(L, S_ISREG(s.st_mode)); lua_settable(L, -3);
		lua_pushstring(L, "isdir"); lua_pushboolean(L, S_ISDIR(s.st_mode)); lua_settable(L, -3);
		lua_pushstring(L, "islnk"); lua_pushboolean(L, S_ISLNK(s.st_mode)); lua_settable(L, -3);
		return 1;
	} else {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
}


static int l_readdir(lua_State *L)
{
	DIR *dir;
	const char *dirname = luaL_checkstring(L, 1);
	struct dirent *de;
	int i =1;

	dir = opendir(dirname);
	if(dir == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
	
	lua_newtable(L);

	while( (de = readdir(dir)) ) {
		lua_pushnumber(L, i++);
		lua_pushstring(L, de->d_name);
		lua_settable(L, -3);
	}

	closedir(dir);

	return 1;
}


static int l_signal(lua_State *L)
{
	int signum;
	int handle;

	signum = luaL_checkoption (L, 1, NULL, signame);
	handle = lua_toboolean(L, 2);
	signal(signum, handle ? signal_handler : SIG_DFL);

	return 0;
}


static int l_signal_set_fd(lua_State *L)
{
	signal_fd = luaL_checknumber(L, 1);
	return 0;
}



static int l_waitpid(lua_State *L)
{
	int pid;
	int status;
	int r;

	pid = lua_tonumber(L, 1);

	r = waitpid(pid, &status, WNOHANG);

	if(r < 0 ) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
	
	if(r == 0) {
		lua_newtable(L);
		lua_pushstring(L, "isrunning");
		lua_pushboolean(L, 1);
		lua_settable(L, -3);
		return 1;
	}

	if(r > 0) {
		lua_newtable(L);
		lua_pushstring(L, "isrunning");
		lua_pushboolean(L, 0);
		lua_settable(L, -3);
		lua_pushstring(L, "exitstatus");
		lua_pushnumber(L, WEXITSTATUS(status));
		lua_settable(L, -3);
		lua_pushstring(L, "ifexited");
		lua_pushnumber(L, WIFEXITED(status));
		lua_settable(L, -3);
		lua_pushstring(L, "ifsignaled");
		lua_pushnumber(L, WIFSIGNALED(status));
		lua_settable(L, -3);
		return 1;
	}

	return 0;
}


static int l_exec(lua_State *L)
{
	int r;
	const char *arg[4];

	arg[0] = "/bin/sh";
	arg[1] = "-c";
	arg[2] = luaL_checkstring(L, 1);
	arg[3] = NULL;

	r = execvp(arg[0], (char * const *) arg);

	if(r == -1) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	} else {
		/* We never ever get here */
	}

	return 0;
}


static int l_forkpty(lua_State *L)
{
	int pid;
	int fd;

	pid = forkpty(&fd, NULL, NULL, NULL);
	
	if(pid == -1) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	} else {
		lua_pushnumber(L, pid);
		lua_pushnumber(L, fd);
		return 2;
	}

	return 0;
}


#define SETGPIOMODE     0x5510  //set gpio mode input = 0 output = 1 
#define GETGPIOMODE     0x5511  //get gpio mode
#define SETGPIOVALUE    0x5512  //set gpio value high = 1 low = 0 
#define GETGPIOVALUE    0x5513  //get gpio value 

#define GPIO1 1
#define GPIO3 3
#define GPIO5 5
#define GPIO7 7

#define GPIO_OUT 1
#define GPIO_IN  0
#define GPIO_HIGH 1
#define GPIO_LOW  0

struct gpio_param {
	int pin_offset;                         
	int pin_mode;
	int pin_value;
};


static int l_gpio_set(lua_State *L)
{
	int fd;
	struct gpio_param gp;
	int r;

	//gp.pin_offset = luaL_checknumber(L, 1) == 0 ? GPIO1 : GPIO3;
	gp.pin_offset = luaL_checknumber(L, 1);
	if (gp.pin_offset<1 || gp.pin_offset>24)
	{
		lua_pushboolean(L, 0);
		lua_pushstring(L, "Incorrect gpio pin offset.");
		return 2;
	}
	
	gp.pin_mode = GPIO_OUT;
	gp.pin_value = lua_tonumber(L, 2) ? GPIO_HIGH : GPIO_LOW;

	//printf(__FILE__ "DEBUG: gpio pin offset = %d, setting to %d", gp.pin_offset, gp.pin_value);

	fd = open("/dev/gpio", O_RDWR);
	if(fd == -1) {
		lua_pushboolean(L, 0);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	r = ioctl(fd, SETGPIOMODE, &gp);
	if(r == -1) {
		lua_pushboolean(L, 0);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	r = ioctl(fd, SETGPIOVALUE, &gp);
	if(r == -1) {
		lua_pushboolean(L, 0);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	close(fd);
		
	lua_pushboolean(L, 1);
	return 1;
}




/***************************************************************************
* Lua binding
***************************************************************************/

static struct luaL_Reg sys_table[] = {
	{ "version",		l_version },
	{ "meminfo",		l_meminfo },
	{ "select",		l_select },
	{ "hirestime",		l_hirestime },
	{ "sleep",		l_sleep },
	{ "get_macaddr",	l_macaddr },
	{ "open",       	l_open },
	{ "close",      	l_close },
	{ "pipe",	      	l_pipe },
	{ "dup2",	      	l_dup2 },
	{ "tcflush",		l_tcflush },
	{ "read",       	l_read },
	{ "readport",		l_readport },
	{ "write",       	l_write },
	{ "fork",       	l_fork },
	{ "set_noncanonical",	l_set_noncanonical },
	{ "set_baudrate",	l_set_baudrate },
	{ "daemonize",		l_daemonize },
	{ "syslog",		l_syslog },
	{ "isatty",		l_isatty },
	{ "lstat",		l_lstat },
	{ "readdir",		l_readdir },
	{ "signal",		l_signal },
	{ "signal_set_fd",	l_signal_set_fd },
	{ "waitpid",		l_waitpid },
	{ "exec",		l_exec },
	{ "forkpty",		l_forkpty },
	{ "gpio_set",		l_gpio_set },
	{ NULL },
};


int luaopen_sys(lua_State *L)
{
	luaL_register(L, "sys", sys_table);
	
	return 0;
}


/*
 * End
 */

