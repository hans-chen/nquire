//
// misc.h
//
// Author: M.R. van dootingh
// Date: febr 5 2010
//

#ifndef nquire_server_misc_h
#define nquire_server_misc_h

#ifdef WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#include <Windows.h>
#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <sys/un.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <resolv.h>
#include <sys/types.h>
#endif

#include <string>
#include <fstream>
#include <iostream>
#include <vector>

std::string bytes_to_text( const std::string txt );
std::string text_to_bytes( const std::string l );
void strip_trailing_return( std::string& line );

// fatal and warnings will always be logged:
#define LOG_FTL( msg ) {log("FTL") << __FILE__ << ":" << __LINE__ << " " << msg << std::endl; exit(-1);}
#define LOG_ERR( msg ) {log("ERR") << __FILE__ << ":" << __LINE__ << " " << msg << std::endl;}
#define LOG_WRN( msg ) {log("WRN") << __FILE__ << ":" << __LINE__ << " " << msg << std::endl;}
#define LOG_INF( msg ) {if( get_log_level() >= 3 ) log("INF") << __FILE__ << ":" << __LINE__ << " " << msg << std::endl;}
#define LOG_DBG( msg ) {if( get_log_level() >= 4 ) log("DBG") << __FILE__ << ":" << __LINE__ << " " << msg << std::endl;}
#define LOG_DMP( msg ) {if( get_log_level() >= 5 ) log("DMP") << __FILE__ << ":" << __LINE__ << " " << msg << std::endl;}

// Default logging is done to stdout; change the log-file with the next function
void set_log_file( std::string filename );

// Set the current log-level (default=3):
// 1=fatal, 2=warning, 3=info, 4=debug, 5=dump
void set_log_level( unsigned int level );

std::vector<std::string> get_local_ip_addresses();

// do not use the next functions direct, just use the LOG_...() macros.
std::ostream& log(const char* label);
unsigned get_log_level();


#endif
