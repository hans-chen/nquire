#include <stdio.h>
#include <arpa/inet.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdarg.h>
#include <sys/select.h>
#include <sys/time.h>
#include <fcntl.h>
#include <assert.h>
#include <errno.h>
#include <netinet/tcp.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>


static int l_socket(lua_State *L)
{
	int fd;
	int type = -1;
	const char *typestr;
	int r;

	typestr = luaL_checkstring(L, 1);
	if(strcmp(typestr, "tcp")==0) type = SOCK_STREAM;
	if(strcmp(typestr, "udp")==0) type = SOCK_DGRAM;
	if(type == -1) {
		lua_pushnil(L);
		return 1;
	}

	fd = socket(AF_INET, type, 0);
	
	if(fd == -1) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	} else {

		r = fcntl(fd, F_GETFL);
		r |= O_NONBLOCK;
		fcntl(fd, F_SETFL, r);

		lua_pushnumber(L, fd);
		return 1;
	}
}


static int l_connect(lua_State *L)
{
	int fd;
	const char *addr;
	int port;
	struct sockaddr_in sa;
	int r;

	fd = luaL_checknumber(L, 1);
	addr = luaL_checkstring(L, 2);
	port = luaL_checknumber(L, 3);

	memset(&sa, 0, sizeof(sa));
	sa.sin_family = AF_INET;
	sa.sin_addr.s_addr = inet_addr(addr);
	sa.sin_port = htons(port);
	
	r = connect(fd, (struct sockaddr *)&sa, sizeof(sa));
	if(r < 0) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushboolean(L, 1);
	return 1;
}


static int l_bind(lua_State *L)
{
	const char *addr;
	int port;
	struct sockaddr_in sa;
	int yes = 1;
	int r;
	int fd;
	
	fd = luaL_checknumber(L, 1);
	addr = luaL_checkstring(L, 2);
	port = luaL_checknumber(L, 3);

	memset(&sa, 0, sizeof(sa));
	sa.sin_family = AF_INET;
	sa.sin_addr.s_addr = inet_addr(addr);
	sa.sin_port = htons(port);
	
	r = setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
	if(r < 0) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	r = bind(fd, (struct sockaddr *)&sa, sizeof(sa));
	if(r < 0) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushnumber(L, 1);
	return 1;
}


static int l_listen(lua_State *L)
{
	int fd;
	int backlog;
	int r;
	
	fd = luaL_checknumber(L, 1);
	backlog = luaL_checkint(L, 2);

	r = listen(fd, backlog);
	if(r < 0) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushnumber(L, 1);
	return 0;
}


static int l_accept(lua_State *L)
{
	int fd;
	int fd_client;
	struct sockaddr_in sa;
	unsigned int salen;
	
	fd = luaL_checknumber(L, 1);

	salen = sizeof(sa);
	fd_client = accept(fd, (struct sockaddr *)&sa, &salen);

	if (fd_client == -1) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	} else {
		lua_pushnumber(L, fd_client);
		lua_pushstring(L, inet_ntoa(sa.sin_addr));
		lua_pushnumber(L, ntohs(sa.sin_port));
		return 3;
	}
}


static int l_send(lua_State *L)
{
	int fd;
	const char *buf;
	size_t buflen;
	int r;
	
	fd = luaL_checknumber(L, 1);
	buf = luaL_checklstring(L, 2, &buflen);

	r = send(fd, buf, buflen, 0);
	if(r < 0) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushnumber(L, r);
	return 1;
}


static int l_sendto(lua_State *L)
{
	int fd;
	const char *buf;
	const char *addr;
	int port;
	size_t buflen;
	int r;
	struct sockaddr_in sa;
	
	fd = luaL_checknumber(L, 1);
	buf = luaL_checklstring(L, 2, &buflen);
	addr = luaL_checkstring(L, 3);
	port = luaL_checknumber(L, 4);

	memset(&sa, 0, sizeof(sa));
	sa.sin_family = AF_INET;
	sa.sin_addr.s_addr = inet_addr(addr);
	sa.sin_port = htons(port);

	r = sendto(fd, buf, buflen, 0, (struct sockaddr *)&sa, sizeof(sa));
	if(r < 0) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushnumber(L, r);
	return 1;
}


static int l_recv(lua_State *L)
{
	int fd;
	char *buf;
	int maxlen;
	int r;

	fd = luaL_checknumber(L, 1);
	maxlen = luaL_checkint(L, 2);

	buf = malloc(maxlen);
	if(! buf) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	r = recv(fd, buf, maxlen, 0);
	if(r < 0) {
		free(buf);
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushlstring(L, buf, r);
	free(buf);
	return 1;
}


static int l_recvfrom(lua_State *L)
{
	int fd;
	char *buf;
	int maxlen;
	int r;
	struct sockaddr_in sa;
	unsigned int salen;

	fd = luaL_checknumber(L, 1);
	maxlen = luaL_checkint(L, 2);
	
	buf = malloc(maxlen);
	if(! buf) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	salen = sizeof(sa);
	r = recvfrom(fd, buf, maxlen, 0, (struct sockaddr *)&sa, &salen);
	if(r < 0) {
		free(buf);
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushlstring(L, buf, r);
	lua_pushstring(L, inet_ntoa(sa.sin_addr));
	lua_pushnumber(L, ntohs(sa.sin_port));
	free(buf);
	return 3;
}


static int l_close(lua_State *L)
{
	int fd;

	fd = luaL_checknumber(L, 1);
	close(fd);
	fd = -1;

	return 0;
}


const char *optname[] = {
	"TCP_NODELAY",		/* 0 */
	"SO_BROADCAST",		/* 1 */
	"SO_REUSEADDR",		/* 2 */
	"IP_ADD_MEMBERSHIP",	/* 3 */
	"IP_MULTICAST_TTL",	/* 4 */
	"SO_ERROR",		/* 5 */
	NULL
};

static int l_getsockopt(lua_State *L)
{
	int fd;
	int opt;
	int ret;
	size_t retsize;

	fd = luaL_checknumber(L, 1);
	opt = luaL_checkoption(L, 2, NULL, optname);

	switch(opt) {
		case 5:
			ret = 0;
			retsize = sizeof ret;
			getsockopt(fd, SOL_SOCKET, SO_ERROR, &ret, &retsize);
			lua_pushnumber(L, ret);
			lua_pushstring(L, strerror(ret));
			return 2;
	}

	lua_pushboolean(L, 0);
	lua_pushstring(L, "Option not supported");
	return 2;
}


static int l_setsockopt(lua_State *L)
{
	int fd;
	int opt;
	const char *valstr;
	int valint;
	int r;
	struct ip_mreq mreq;

	fd = luaL_checknumber(L, 1);
	opt = luaL_checkoption(L, 2, NULL, optname);

	switch(opt) {
		case 0:
			valint = luaL_checknumber(L, 3);
			r = setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, (void *)&valint, sizeof valint);
			break;
		case 1:
			valint = luaL_checknumber(L, 3);
			r = setsockopt(fd, SOL_SOCKET, SO_BROADCAST, (void *)&valint, sizeof valint);
			break;
		case 2:
			valint = luaL_checknumber(L, 3);
			r = setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&valint, sizeof valint);
			break;
		case 3:
			valstr = luaL_checkstring(L, 3);
			bzero(&mreq, sizeof mreq);
			mreq.imr_interface.s_addr = htonl(INADDR_ANY);
			mreq.imr_multiaddr.s_addr = inet_addr(valstr);
			r = setsockopt(fd, SOL_IP, IP_ADD_MEMBERSHIP, (void *)&mreq, sizeof mreq);
			break;
		case 4:
			valint = luaL_checknumber(L, 3);
			r = setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, (void *)&valint, sizeof valint);
			break;
		default:
			r = 0;
	}

	if(r == 0) {
		lua_pushboolean(L, 1);
		return 1;
	} else {
		lua_pushboolean(L, 0);
		lua_pushstring(L, strerror(errno));
		return 2;
	}
}



/***********************************************************************
* Lua interfacing
***********************************************************************/

	
static struct luaL_Reg net_table[] = {
	{ "socket",	l_socket },
	{ "bind",	l_bind },
	{ "accept",	l_accept },
	{ "connect",	l_connect },
	{ "listen",	l_listen },
	{ "send",	l_send },
	{ "sendto",	l_sendto },
	{ "recv",	l_recv },
	{ "recvfrom",	l_recvfrom },
	{ "close",	l_close },
	{ "setsockopt", l_setsockopt },
	{ "getsockopt", l_getsockopt },
	{ NULL },
};


int luaopen_net(lua_State *L)
{
	luaL_register(L, "net", net_table);
	return 1;
}

/*
 * End
 */
