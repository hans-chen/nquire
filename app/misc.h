#ifndef misc_h
#define misc_h

#define BARF(L, msg...) do { lua_pushnil(L); lua_pushfstring(L, msg); return 2; } while(0)

#ifdef TRACEON
#include <stdarg.h>
void trace_header( const char* file, int line, const char* function )
{
	printf("%s:%d - %s", file, line, function);
}
// function style trace!
#define TRACE(msg...) do{trace_header(__FILE__,__LINE__,__FUNCTION__);printf(" "msg); printf("\n");}while(0)
#define TRACE_NB(msg...) do{trace_header(__FILE__,__LINE__,__FUNCTION__);printf(" "msg);}while(0)
#define TRACE_PRINTF(msg...) printf(" "msg)
#else
#define TRACE(msg...) do{}while(0)
#define TRACE_NB(msg...) do{}while(0)
#define TRACE_PRINTF(msg...) do{}while(0)
#endif

#endif
