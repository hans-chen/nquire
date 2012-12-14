/*
 * Copyright © 2007 All Rights Reserved.
 */

#include <nlrf.h>

#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#define BARF(L, msg...) do { lua_pushnil(L); lua_pushfstring(L, msg); return 2; } while(0)

//#define TRACE(msg...) { fprintf(stdout,"%s:%d - %s ", __FILE__, __LINE__, __FUNCTION__);fprintf(stdout,msg);fprintf(stdout,"\n"); }
#define TRACE(msg...) {}

typedef struct {

	lua_State *L;

	char *device_name;
	int fd;
} Mifare;


static int l_new(lua_State *L)
{
	TRACE(" ");

	Mifare *dd = lua_newuserdata(L, sizeof *dd);
	if(dd == NULL) {
		lua_pushnil(L);
		lua_pushstring(L, "Can't allocate mifare");
		return 2;
	}

	memset(dd, 0, sizeof *dd);
	luaL_getmetatable(L, "Mifare");
	lua_setmetatable(L, -2);

	return 1;
}

// open mifare rfid device
// @param: L[1] - device name
// @return: the file descriptor
static int l_open(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);

	// Parse arguments
	const char *device_name = lua_tostring(L, 2);

	TRACE(" device_name = %s", device_name);

	// innitialize
	dd->device_name = (char*)malloc( strlen( device_name )+1 );
	strcpy( dd->device_name, device_name );

	// functional implementation
	dd->fd = nlrf_open(dd->device_name);
	TRACE(" fd = %d", dd->fd);
	
	// return parameters
	lua_pushnumber(L, dd->fd);
	return 1;
}


//  
static int l_close(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);
	TRACE(" fd = %d", dd->fd);

	nlrf_close(dd->fd);
	dd->fd = 0;
	free(dd->device_name);
	dd->device_name = 0;

	return 0;
}


// 
static int l_free(lua_State *L) 
{ 
	Mifare *dd = lua_touserdata(L, 1);
	TRACE(" ");

	l_close(L);
	free(dd);

	return(0); 
}

// @return result, nsector, nblock, blocksize, cardnum
static int l_querycardinfo(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);
	TRACE(" fd = %d", dd->fd);

	if( dd->fd == 0 )
	{
		BARF(L,"Interface not opened");
		lua_pushnumber(L, -1);	
		return 1;
	}

	struct nlrf_cardinfo info;
	int result = nlrf_querycardinfo(dd->fd, &info);
	lua_pushnumber(L, result);
	switch( result )
	{
	case 0:
		TRACE(" ");
		lua_pushnumber(L, info.nsector);
		lua_pushnumber(L, info.nblock);
		lua_pushnumber(L, info.blocksize);
		lua_pushlstring(L, info.cardnum, 4);
		return 5;
	default:
		return 1;
	}
}


// async querycardinfo, use fetch_querycardinfo to get the result
// A file event wil happen when there is data, or when 3 seconds have passed
// @return result
int l_send_querycardinfo(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);
	TRACE(" fd = %d", dd->fd);

	if( dd->fd == 0 )
	{
		BARF(L,"Interface not opened");
		lua_pushnumber(L, -1);	
		return 1;
	}

	int result = nlrf_send_querycardinfo(dd->fd);

	lua_pushinteger(L, result);
	return 1;
}

// async querycardinfo, use send_querycardinfo to innitiate the request
// A file event wil happen when there is data, or when 3 seconds have passed
// @return result[, nsector, nblock, blocksize, cardnum]
int l_fetch_querycardinfo(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);
	TRACE(" fd = %d", dd->fd);

	if( dd->fd == 0 )
	{
		BARF(L,"Interface not opened");
		lua_pushnumber(L, -1);	
		return 1;
	}

	struct nlrf_cardinfo info;
	memset(&info,0,sizeof(info));
	int result = nlrf_fetch_querycardinfo(dd->fd, &info);
	lua_pushinteger(L, result);
	switch( result )
	{
	case 0:
		TRACE(" ");

		TRACE("nsector=%d, nblock=%d, blocksize=%d, cardnum=%02x%02x%02x%02x",
				info.nsector, info.nblock, info.blocksize, 
				info.cardnum[0], info.cardnum[1], info.cardnum[2], info.cardnum[3]);

		lua_pushnumber(L, info.nsector);
		lua_pushnumber(L, info.nblock);
		lua_pushnumber(L, info.blocksize);
		lua_pushlstring(L, info.cardnum, 4);

		return 5;
	default:
		return 1;
	}
}


// @param L[2] the access key to the mifare card
static int l_chkkey(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);
	unsigned int length=0U;
	const char *key = lua_tolstring(L, 2, &length);
	TRACE(" length=%d", length);
	TRACE(" key='%02x%02x %02x%02x %02x%02x %02x%02x %02x%02x %02x%02x'", 
		key[0],key[1],key[2],key[3], key[4],key[5],key[6],key[7], key[8],key[9],key[10],key[11]);

	int result = nlrf_chkkey(dd->fd, (const unsigned char*)key, length);

	lua_pushnumber(L, result);

	return 1;
}

// @param L[2] - sectornr
// @param L[3] - blocknr
// @param L[4] - size
// return result, data
static int l_readblock(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);

	if( dd->fd == 0 )
	{
		BARF(L,"Interface not opened");
		lua_pushnumber(L, -1);	
		return 1;
	}
	int sector = lua_tointeger(L, 2);
	int block = lua_tointeger(L, 3);
	int size = lua_tointeger(L, 4);

	unsigned char *data = (unsigned char*)malloc( size );
	if( !data )
	{
		BARF(L,"Could not allocate %d bytes: not performing nlrf_readblock()", size);
		lua_pushnumber(L, -1);
		return 1;
	}
	else
	{
		memset(data,0,size);
		TRACE(" fd=%d, sector=%d, block=%d, size=%d", dd->fd, sector, block, size);

		int result = nlrf_readblock(dd->fd, sector, block, data, size);

		lua_pushnumber(L, result);
		int numpar = 1;
		if (result == 0)
		{
			lua_pushlstring( L, (const char*)data, size );
			numpar = 2;
		}

		free(data);
		return numpar;
	}
}


/***************************************************************************
* Lua bindings
***************************************************************************/

static struct luaL_Reg mifare_metatable[] = {
	{ "open",			l_open },
	{ "close",			l_close },
	{ "querycardinfo",	l_querycardinfo }, 
	{ "send_querycardinfo",  l_send_querycardinfo },
	{ "fetch_querycardinfo", l_fetch_querycardinfo },
	{ "chkkey",			l_chkkey },
	{ "readblock",		l_readblock },

	{ NULL },
};


static struct luaL_Reg mifare_table[] = {
	{ "new",	l_new },
	{ "__gc",	l_free },
	{ NULL },
};

int luaopen_mifare(lua_State *L)
{
	TRACE(" ");
	luaL_newmetatable(L, "Mifare"); 
	lua_pushstring(L, "__index");
	lua_pushvalue(L, -2); 
	lua_settable(L, -3); 

	luaL_register(L, NULL, mifare_metatable);
	luaL_register(L, "mifare", mifare_table);

	return 0;
}


/*
 * End
 */

