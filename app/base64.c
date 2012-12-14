#include <stdlib.h>
#include <string.h>

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>


static char base64_chars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static int pos(char c)
{
	char *p;
	for (p = base64_chars; *p; p++)
		if (*p == c)
			return p - base64_chars;
	return -1;
}

int base64_encode(const void *data, int size, char **str)
{
	char *s, *p;
	int i;
	int c;
	const unsigned char *q;

	p = s = (char *) malloc(size * 4 / 3 + 4);
	if (p == NULL)
		return -1;
	q = (const unsigned char *) data;
	i = 0;
	for (i = 0; i < size;) {
		c = q[i++];
		c *= 256;
		if (i < size)
			c += q[i];
		i++;
		c *= 256;
		if (i < size)
			c += q[i];
		i++;
		p[0] = base64_chars[(c & 0x00fc0000) >> 18];
		p[1] = base64_chars[(c & 0x0003f000) >> 12];
		p[2] = base64_chars[(c & 0x00000fc0) >> 6];
		p[3] = base64_chars[(c & 0x0000003f) >> 0];
		if (i > size)
			p[3] = '=';
		if (i > size + 1)
			p[2] = '=';
		p += 4;
	}
	*p = 0;
	*str = s;
	return strlen(s);
}

#define DECODE_ERROR 0xffffffff

static unsigned int token_decode(const char *token)
{
	int i;
	unsigned int val = 0;
	int marker = 0;
	if (strlen(token) < 4)
		return DECODE_ERROR;
	for (i = 0; i < 4; i++) {
		val *= 64;
		if (token[i] == '=')
			marker++;
		else if (marker > 0)
			return DECODE_ERROR;
		else
			val += pos(token[i]);
	}
	if (marker > 2)
		return DECODE_ERROR;
	return (marker << 24) | val;
}

int base64_decode(const char *str, void *data)
{
	const char *p;
	unsigned char *q;

	q = data;
	for (p = str; *p && (*p == '=' || strchr(base64_chars, *p)); p += 4) {
		unsigned int val = token_decode(p);
		unsigned int marker = (val >> 24) & 0xff;
		if (val == DECODE_ERROR)
			return -1;
		*q++ = (val >> 16) & 0xff;
		if (marker < 2)
			*q++ = (val >> 8) & 0xff;
		if (marker < 1)
			*q++ = val & 0xff;
	}
	return q - (unsigned char *) data;
}


/***************************************************************************
* Lua binding
***************************************************************************/

int l_encode(lua_State *L)
{
	const char *buf_in;
	size_t len_in;
	char *buf_out = NULL;
	size_t len_out;

	buf_in = luaL_checklstring(L, 1, &len_in);
	len_out = base64_encode(buf_in, len_in, &buf_out);
	lua_pushlstring(L, buf_out, len_out);
	free(buf_out);
	return 1;
}

int l_decode(lua_State *L)
{
	const char *buf_in;
	size_t len_in;
	char *buf_out;
	int len_out;

	buf_in = luaL_checklstring(L, 1, &len_in);
	buf_out = malloc(len_in);
	len_out = base64_decode(buf_in, buf_out);
	if(len_out >= 0) {
		lua_pushlstring(L, buf_out, len_out);
	} else {
		lua_pushnil(L);
	}
	free(buf_out);
	return 1;
}


static struct luaL_Reg base64_table[] = {
	{ "encode",		l_encode },
	{ "decode",		l_decode },
	{ NULL },
};


int luaopen_base64(lua_State *L)
{
	luaL_register(L, "base64", base64_table);
	
	return 0;
}


/*
 * vi: ft=c ts=4 sw=4 
 */
