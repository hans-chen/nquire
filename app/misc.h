#ifndef misc_h
#define misc_h

#define BARF(L, msg...) do { lua_pushnil(L); lua_pushfstring(L, msg); return 2; } while(0)

#ifdef DEBUG
#include <stdarg.h>
void trace( const char* file, int line, const char* function, const char* format, ... )
{
	printf("%s:%d - %s", file, line, function);
	va_list args;
	va_start (args, format);
	vfprintf (stdout, format, args);
	va_end (args);
	printf("\n");
	fflush(stdout);
}
// function style trace!
#define TRACE(msg...) trace( __FILE__, __LINE__, __FUNCTION__, " "msg )
#else
#define TRACE(msg...) do{}while(0)
#endif

#endif
