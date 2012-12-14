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

//#define DEBUG
#include "misc.h"

typedef struct {

	lua_State *L;

	char *device_name;
	int fd;
} Mifare;


/* convert the errornumber into a string in an consistent value (independent of what nlrf.h defines) */
static int mifare_error( int nlrf_error )
{
	switch( nlrf_error )
	{
		case NLRF_OK: return 0;
		case -NLRF_ERR_NODEV: return -1;
    	case -NLRF_ERR_NOCARD: return -2;
    	case -NLRF_ERR_WRONGKEY: return -3;
    	case -NLRF_ERR_CARDORKEY: return -4;
    	case -NLRF_ERR_IGNORE_ME: return -5;
    	case -NLRF_ERR_INVALID: return -6;
    	case -NLRF_ERR_SETTTY: return -7;
    	case -NLRF_ERR_BACKUPTTY: return -8;
    	case -NLRF_ERR_RESTORETTY: return -9;
    	case -NLRF_ERR_UNKNOWN: return -10;
    	default: return -100;
    }
}

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

	// innitialize
	dd->device_name = (char*)malloc( strlen( device_name )+1 );
	strcpy( dd->device_name, device_name );

	// functional implementation
	TRACE("before: nlrf_open( devicename = %s )", dd->device_name);
	dd->fd = nlrf_open(dd->device_name);
	TRACE("after: nlrf_open, fd = %d", dd->fd);
	
	// return parameters
	lua_pushnumber(L, dd->fd);
	return 1;
}


//
static int l_close(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);

	if( dd->fd )
	{
		TRACE("before: nlrf_close( fd = %d )", dd->fd);
		nlrf_close(dd->fd);
		TRACE("after: nlrf_close");
		dd->fd = 0;
		free(dd->device_name);
		dd->device_name = 0;
	}
	
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

	if( dd->fd == 0 ) BARF(L,"Interface not opened");

	struct nlrf_cardinfo info;
	TRACE("before: nlrf_querycardinfo");
	int result = nlrf_querycardinfo(dd->fd, &info);
	TRACE("after: nlrf_querycardinfo, result=%d", result);
	lua_pushinteger(L, mifare_error(result));
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

	if( dd->fd == 0 ) BARF(L,"Interface not opened");

	TRACE("before: nlrf_send_querycardinfo");
	int result = nlrf_send_querycardinfo(dd->fd);
	TRACE("after: nlrf_sendquerycardinfo, result=%d", result);

	lua_pushinteger(L, mifare_error(result));
	return 1;
}

// async querycardinfo, use send_querycardinfo to innitiate the request
// A file event wil happen when there is data, or when 3 seconds have passed
// @return result[, nsector, nblock, blocksize, cardnum]
int l_fetch_querycardinfo(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);
	TRACE(" fd = %d", dd->fd);

	if( dd->fd == 0 ) BARF(L,"Interface not opened");

	struct nlrf_cardinfo info;
	memset(&info,0,sizeof(info));
	TRACE("before: nlrf_fetch_querycardinfo");
	int result = nlrf_fetch_querycardinfo(dd->fd, &info);
	TRACE("after: nlrf_fetch_querycardinfo, result=%d", result);
	lua_pushinteger(L, mifare_error(result));
	switch( result )
	{
	case 0:
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
	TRACE("before: nlrf_chkkey( key='%02x%02x %02x%02x %02x%02x %02x%02x %02x%02x %02x%02x', length=%d )", 
			key[0],key[1],key[2],key[3], key[4],key[5],
			key[6],key[7], key[8],key[9],key[10],key[11], 
			length);
	int result = nlrf_chkkey(dd->fd, (const unsigned char*)key, length);
	TRACE("after: nlrf_chkkey, result = %d", result);

	lua_pushinteger(L, mifare_error(result));

	return 1;
}

// @param L[2] - sectornr
// @param L[3] - blocknr
// @param L[4] - size
// return result, data
static int l_readblock(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);

	if( dd->fd == 0 ) BARF(L,"Interface not opened");

	int sector = lua_tointeger(L, 2);
	int block = lua_tointeger(L, 3);
	int size = lua_tointeger(L, 4);

	unsigned char *data = (unsigned char*)malloc( size );
	if( !data ) 
	{
		BARF(L,"Could not allocate %d bytes: not performing nlrf_readblock()", size);
	}
	else
	{
		memset(data,0,size);
		TRACE("before: nlrf_readblock( fd=%d, sector=%d, block=%d, size=%d )", dd->fd, sector, block, size);
		int result = nlrf_readblock(dd->fd, sector, block, data, size);
		TRACE("after: nlrf_readblock, result=%d", result);

		lua_pushinteger(L, mifare_error(result));
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

static int l_get_modeltype(lua_State *L)
{
	Mifare *dd = lua_touserdata(L, 1);

	if( dd->fd == 0 ) BARF(L,"Interface not opened");

	switch(nlrf_get_modeltype(dd->fd))
	{
	case NLRF_MODEL_V1: lua_pushinteger( L, 1 ); break;
	case NLRF_MODEL_V2: lua_pushinteger( L, 2 ); break;
	default: lua_pushinteger( L, -1 ); break;
	}
	return 1;
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
	{ "get_modeltype",	l_get_modeltype },
	
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
 * vi: ft=c ts=4 sw=4 
 */
