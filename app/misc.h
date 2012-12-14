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
static int misc_dotrace = 0;
#define TRACE_ON() do{misc_dotrace=1;}while(0)
#define TRACE_OFF() do{misc_dotrace=0;}while(0)
// function style trace!
#define TRACE(msg...) do{if(misc_dotrace) trace( __FILE__, __LINE__, __FUNCTION__, " "msg );}while(0)
#else
#define TRACE_ON() do{}while(0)
#define TRACE_OFF() do{}while(0)
#define TRACE(msg...) do{}while(0)
#endif

#endif
