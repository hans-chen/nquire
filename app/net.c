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
#include <sys/types.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <assert.h>
#include <errno.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <netinet/ether.h>
#include <net/if.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <netdb.h>

#include "misc.h"

#ifdef TRACEON
static int test_nonblock( int fd )
{
	return fcntl(fd, F_GETFL) & O_NONBLOCK;
}
#endif

static void set_nonblocking( int fd )
{
	int r = fcntl(fd, F_GETFL);
	if (r!=-1) 
		fcntl(fd, F_SETFL, r | O_NONBLOCK);
}

static int l_socket(lua_State *L)
{
	int fd;
	int type = -1;
	const char *typestr;

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

		TRACE( "socket = %d", fd );

		set_nonblocking( fd );

		lua_pushnumber(L, fd);
		return 1;
	}
}

/* get host ip address(es) by name
 * IN: hostname
 * return: 
 *    ips      array with ip-address(es) for specified hostname
 *    errstr   ips==nil ? "<error-text>" : nil
 *    errnr    ips==nil ? "<error-number>" : nil
 * NOTE: currently only ipv6 is supported
 */
static int l_gethostbyname( lua_State *L )
{
	const char *node = luaL_checkstring(L, 1);
	struct addrinfo hints;
	memset( &hints, 0, sizeof(hints) );
	hints.ai_family = AF_INET;
	
	struct addrinfo * result;
	int error = getaddrinfo( node, 0, &hints, &result );
	if( error != 0 )
	{
		lua_pushnil( L );
		lua_pushstring( L, gai_strerror(error) );
		lua_pushnumber( L, error );
		return 3;
	}
	struct addrinfo *res;
	int addr_counter = 0;
	
	lua_newtable(L);

	for( res = result; res != 0; res = res->ai_next )
	{
		// only push the address on the stack when it is unique
		struct addrinfo *fres;
		for( fres = result; fres != res && memcmp(fres->ai_addr,res->ai_addr,sizeof(struct sockaddr_in)) != 0; fres = fres->ai_next )
		{}
		if( fres == res )
		{
			char s[INET_ADDRSTRLEN];
			struct sockaddr_in *sa = (struct sockaddr_in*)res->ai_addr;
			inet_ntop(sa->sin_family, &sa->sin_addr, s, sizeof(s));
			addr_counter++;
		
			lua_pushnumber(L, addr_counter);
			lua_pushstring(L, s);
			lua_settable(L, -3);
		}
	}
	freeaddrinfo( result );
	return 1;
}


/* connect socket to server (tcp sockets only)
 * @param l[1]   socket descriptor
 * @param l[2]   ipv4 address (string presentation format)
 * @param l[3]   port
 * @return 0=ok | 
 *        1=operation in progress |
 *        -1=try again later, <error string> |
 *        -2=error, <error string>
*/
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
	if( inet_pton( AF_INET, addr, &sa.sin_addr ) != 1)
	{
		lua_pushinteger(L, -2);
		lua_pushstring(L, "Address not parsable as IPV4");
		return 2;
	}
	
	//TRACE("name = %s, addr = %u.%u.%u.%u", he->h_name, (unsigned char)he->h_addr[0], (unsigned char)(he->h_addr[1]), (unsigned char)he->h_addr[2], (unsigned char)he->h_addr[3] );
	//sa.sin_addr.s_addr = *((in_addr_t *)(he->h_addr));//inet_addr(he->h_addr);
	sa.sin_port = htons(port);
	
	r = connect(fd, (struct sockaddr *)&sa, sizeof(sa));
	if( r<0 )
	{
		if( errno == EINPROGRESS ){
			lua_pushinteger(L, 1);
			return 1;
		}
		else
		{
			lua_pushinteger(L, -2);
			lua_pushstring(L, strerror(errno));
			return 2;
		}
	}

	lua_pushinteger(L, 0);
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

// accept a tcp connection
// @param L[1]    the socket file descriptor
// @param L[2]    optional sendbuffersize (to enlarge the default size)
static int l_accept(lua_State *L)
{
	int fd = luaL_checknumber(L, 1);
	int sock_buf_size = luaL_optnumber( L, 2, -1 );

	struct sockaddr_in sa;
	unsigned int salen = sizeof(sa);
TRACE("Before accept( fd=%d, nonblock=0x%x )", fd, test_nonblock(fd));
	int fd_client = accept(fd, (struct sockaddr *)&sa, &salen);
TRACE("After accept: r=%d", fd_client);


	if (fd_client == -1) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	} else {

		TRACE( "accept socket = %d", fd_client );

		// and explicit set the socket to nonblocking
		// (linux sockets won't inherit socket attributes)
		set_nonblocking( fd_client );

		if( sock_buf_size > 0 )
		{
			// try with a larger sendbuf
			int r = setsockopt( fd_client, SOL_SOCKET, SO_SNDBUF,
		               (char *)&sock_buf_size, sizeof(sock_buf_size) );
			TRACE("setsockopt( SO_SNDBUF = %d ) = %d", sock_buf_size, r );
			if(r) {}
		}

		lua_pushnumber(L, fd_client);
		lua_pushstring(L, inet_ntoa(sa.sin_addr));
		lua_pushnumber(L, ntohs(sa.sin_port));
		return 3;
	}
}


static int l_send(lua_State *L)
{
	int fd = luaL_checknumber(L, 1);
	size_t buflen=0;
	const char *buf = luaL_checklstring(L, 2, &buflen);

TRACE("Before send( fd=%d, nonblock=0x%x )", fd, test_nonblock(fd));
	int r = send(fd, buf, buflen, 0);
TRACE("After send: r=%d (%s), buflen=%d", r, r==EAGAIN ? "EAGAIN" : "", buflen);

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

TRACE("Before sendto( fd=%d, nonblock=0x%x )", fd, test_nonblock(fd));
	r = sendto(fd, buf, buflen, 0, (struct sockaddr *)&sa, sizeof(sa));
TRACE("After sendto: r=%d (%s), buflen=%d", r, r==EAGAIN ? "EAGAIN" : "", buflen);

	if(r < 0) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	lua_pushnumber(L, r);
	return 1;
}

/* l_recv
* @param L[1]	filedescriptor
* @param L[2]	maxlen of bytes to read
* @param L[3]	peek (optional) nil, 0 (false), 1 (true)
* @return n, err	n can be 0 in which case there was no data, when n==nil then err is the errortext
*/
static int l_recv(lua_State *L)
{
	int fd = luaL_checknumber(L, 1);
	int maxlen = luaL_checkint(L, 2);
	int flags = luaL_optint(L, 3, 0) == 0 ? 0 : MSG_PEEK;
	TRACE("(fd=%d, maxlen=%d, flags=%d)", fd, maxlen, flags);

	char *buf = malloc(maxlen);
	if(! buf) {
		lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
		return 2;
	}

	memset( buf, 0, maxlen );
TRACE("Before recv( fd=%d, nonblock=0x%x )", fd, test_nonblock(fd));
	int r = recv(fd, buf, maxlen, flags);
TRACE("After recv: r=%d (%s)", r, r==EAGAIN ? "EAGAIN" : "");

	if( r == -1 && errno == EAGAIN )
		r = 0;
	else if( r <= 0 )
	{
		free(buf);
		lua_pushnil(L);
		if( r < 0 )
			lua_pushstring(L, strerror(errno));
		else
			lua_pushstring(L, "Peer disconnect");
		return 2;
	}
	TRACE("chars = %d", r);

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
TRACE("Before recvfrom( fd=%d, nonblock=0x%x )", fd, test_nonblock(fd));
	r = recvfrom(fd, buf, maxlen, 0, (struct sockaddr *)&sa, &salen);
TRACE("After recvfrom: r=%d (%s)", r, r==EAGAIN ? "EAGAIN" : "");
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

// shut down a socket
// See man -s 2 shutdown
// @par : "RD", "WR", "RDWR"
// @return 
//		true             == OK
//		false,"error"    == error
static int l_shutdown(lua_State *L)
{
	int s = luaL_checkint(L, 1);
	const char *how = luaL_checkstring(L, 2);

	if( strcmp( how, "RD" ) == 0 )
		shutdown(s,SHUT_RD);
	else if( strcmp( how, "WR" ) == 0 )
		shutdown(s,SHUT_WR);
	else if ( strcmp( how, "RDWR" ) == 0 )
		shutdown(s,SHUT_RDWR);
	else
	{
		lua_pushnil( L );
		lua_pushstring( L, "Incorrect parameter 'how' for shutdown socket");
		return 2;
	}
	
	lua_pushboolean(L, 1);
	return 1;
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
	"SO_KEEPALIVE", /* 6 */
	NULL
};

static int l_getsockopt(lua_State *L)
{
	int fd;
	int opt;
	int ret;
	socklen_t retsize;

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
			TRACE("TCP_NODELAY %d", valint);
			r = setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, (void *)&valint, sizeof valint);
			break;
		case 1:
			valint = luaL_checknumber(L, 3);
			TRACE("SO_BROADCAST %d", valint);
			r = setsockopt(fd, SOL_SOCKET, SO_BROADCAST, (void *)&valint, sizeof valint);
			break;
		case 2:
			valint = luaL_checknumber(L, 3);
			TRACE("SO_REUSEADDR %d", valint);
			r = setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&valint, sizeof valint);
			break;
		case 3:
			valstr = luaL_checkstring(L, 3);
			TRACE("IP_ADD_MEMBERSHIP %s", valstr);
			bzero(&mreq, sizeof mreq);
			mreq.imr_interface.s_addr = htonl(INADDR_ANY);
			mreq.imr_multiaddr.s_addr = inet_addr(valstr);
			r = setsockopt(fd, SOL_IP, IP_ADD_MEMBERSHIP, (void *)&mreq, sizeof mreq);
			break;
		case 4:
			valint = luaL_checknumber(L, 3);
			TRACE("IP_MULTICAST_TTL %d", valint);
			r = setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, (void *)&valint, sizeof valint);
			break;
		case 6:
			valint = luaL_checknumber(L, 3);
			TRACE("SO_KEEPALIVE %d", valint);
			r = setsockopt(fd, SOL_SOCKET, SO_KEEPALIVE, &valint, sizeof(valint));
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

// get the ip address associated to an interface
// This is better than using 'ifconfig' and parsing the output because:
//   - it will not 'hang' on driver load problems (wifi)
//   - it does not depend on a certain output format
static int l_get_interface_ip(lua_State *L)
{
	const char* interface = luaL_checkstring(L, 1);

	int fd;
	struct ifreq ifr;

	fd = socket(AF_INET, SOCK_DGRAM, 0);

	/* Only IPv4 IP address */
	ifr.ifr_addr.sa_family = AF_INET;

	/* attach to interface (eth0, wlan0, gprs, ...) */
	strncpy(ifr.ifr_name, interface, IFNAMSIZ-1);

	if (ioctl(fd, SIOCGIFFLAGS, &ifr) < 0) 
	{
		close(fd);
        lua_pushnil(L);
        lua_pushstring(L, strerror(errno));
        //lua_pushstring(L, "Error requesting interface flags" );
        return 2;
    }
    
    if ((ifr.ifr_flags & IFF_UP) == 0 )
    {
		close(fd);
	    lua_pushnil(L);
	    return 1;
	}

	if (ioctl(fd, SIOCGIFADDR, &ifr) < 0)
	{
		close(fd);
        lua_pushnil(L);
		lua_pushstring(L, strerror(errno));
        //lua_pushstring(L, "Error requesting ip address of interface" );
        return 2;
    }

	close(fd);

	/* display result */
	const char* ips = inet_ntoa(((struct sockaddr_in *)&ifr.ifr_addr)->sin_addr);
	lua_pushstring(L, ips );

	return 1;
}

// get the mac-address of an interface
static int l_get_interface_mac(lua_State *L)
{
	const char* interface = luaL_checkstring(L, 1);

	int fd;
	struct ifreq ifr;

	fd = socket(AF_INET, SOCK_DGRAM, 0);

	/* Only IPv4 IP address */
	ifr.ifr_addr.sa_family = AF_INET;

	/* attach to interface (eth0, wlan0, gprs, ...) */
	strncpy(ifr.ifr_name, interface, IFNAMSIZ-1);

	if (ioctl(fd, SIOCGIFHWADDR, &ifr) < 0) 
	{
		close(fd);
        lua_pushnil(L);
        lua_pushstring(L, "Error requesting mac-address" );
        return 2;
    }

	close(fd);

	/* display result */
	char mac[18];
	memset( mac, 0, sizeof(mac) );
	snprintf(mac, 18, "%02x:%02x:%02x:%02x:%02x:%02x",
            (unsigned)(unsigned char)(ifr.ifr_hwaddr.sa_data[0]),
            (unsigned)(unsigned char)(ifr.ifr_hwaddr.sa_data[1]),
            (unsigned)(unsigned char)(ifr.ifr_hwaddr.sa_data[2]),
            (unsigned)(unsigned char)(ifr.ifr_hwaddr.sa_data[3]),
            (unsigned)(unsigned char)(ifr.ifr_hwaddr.sa_data[4]),
            (unsigned)(unsigned char)(ifr.ifr_hwaddr.sa_data[5]) );

	lua_pushstring(L, mac );

	return 1;
}

/***********************************************************************
* Lua interfacing
***********************************************************************/

	
static struct luaL_Reg net_table[] = {
	{ "socket",	l_socket },
	{ "gethostbyname", l_gethostbyname },
	{ "bind",	l_bind },
	{ "accept",	l_accept },
	{ "connect",	l_connect },
	{ "listen",	l_listen },
	{ "send",	l_send },
	{ "sendto",	l_sendto },
	{ "recv",	l_recv },
	{ "recvfrom",	l_recvfrom },
	{ "shutdown", l_shutdown },
	{ "close",	l_close },
	{ "setsockopt", l_setsockopt },
	{ "getsockopt", l_getsockopt },
	{ "get_interface_ip", l_get_interface_ip },
	{ "get_interface_mac", l_get_interface_mac },
	{ NULL },
};


int luaopen_net(lua_State *L)
{
	luaL_register(L, "net", net_table);
	return 1;
}


/*
 * vi: ft=c ts=4 sw=4 
 */
