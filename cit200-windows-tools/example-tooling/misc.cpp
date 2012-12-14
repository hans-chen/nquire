//
// misc.cpp
//
// Author: M.R. van dootingh
// Date: febr 5 2010
//

#include "misc.h"
#include <string>
#include <sstream>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <time.h>
#include <ios>
#ifdef WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#include <iphlpapi.h>
#else
#include <ifaddrs.h>
#endif
#include <assert.h>

using namespace std;


ofstream the_log_file;
static unsigned int the_log_level = 3;

ostream& log(const char* label)
{
	static unsigned count = 0;
	ostream *l = &clog;
	if( the_log_file.is_open() )
		l = &the_log_file;
	
	time_t now = time(0);
	struct tm *gmnow = localtime( &now );
	char stime[80];
	strftime(stime, sizeof(stime), "%Y-%m-%d %H:%M:%S", gmnow);
	
	*l << "[" << stime << " #" << ++count << " " << label << "] " << flush;
	
	return *l;
}

void set_log_file( string filename )
{
	if( the_log_file.is_open() )
		the_log_file.close();

	if( filename=="-" )
		return;

	the_log_file.open( filename.c_str(), ios::app );
	if( the_log_file.fail() )
		the_log_file.open( filename.c_str() );
}

void set_log_level( unsigned int level )
{
	the_log_level = level > 5 ? 5 : level;
}

unsigned get_log_level( )
{
	return the_log_level;
}

// show txt in text format (non printable chars shown as \xnn)
// buff should be big enough!
string bytes_to_text( const string txt )
{
	stringstream buff;
	for( unsigned itxt = 0; itxt< txt.size(); itxt++ )
	{
		unsigned char c = txt[itxt];
		switch( c )
		{
		case '\n': buff << "\\n"; break;
		case '\r': buff << "\\r"; break;
		case '\t': buff << "\\t"; break;
		case '\x1d': buff << "\\e"; break;
		case '\\': buff << "\\\\"; break;
		case '[':
		case ']':
		case '$':
		case '#':
			buff << "\\" << c;
			break;
		default:
			if( c<0x20 || c>0x7f )
				buff << "\\x" << hex << setw(2) << setfill('0') << (unsigned)(c);
			else
				buff << c;
			break;
		}
	}
	return buff.str();
}


// for now, only "\[", "\]", "\$", "\\", "\#", "\n", "\r", "\e" and "\xnn" are interpreted
std::string text_to_bytes( const std::string line )
{
	string b;
	unsigned i = 0;
	while( i<line.size() )
	{
		if( line[i] != '\\' )
		{
			b += line[i]; ++i;
		}
		else
		{
			++i;
			switch( line[i] )
			{
				case '[':
				case ']':
				case '$':
				case '#':
				case '\\': b += line[i]; ++i; break;
				case 'n' : b += '\n'; ++i;	break;
				case 'r' : b += '\r'; ++i;	break;
				case 't' : b += '\t'; ++i;	break;
				case 'e' : b += '\x1b'; ++i;	break;
				case 'x':
				{
					i++;
					istringstream buff(line.substr(i, 2));
					int c;
					buff >> hex >> setw(2) >> c;
					b += (char)(c);
					i+=2;
					break;
				}
				default:
					b += '\\';
					b += line[i]; ++i;
					break;
			}
		}
	}
	return b;
}

void strip_trailing_return( string& line )
{
	if( line.size() > 0  && *line.rbegin() == '\n' )
		line.resize(line.size()-1);
	
}

#ifdef WIN32
std::vector<string> get_local_ip_addresses()
{
	// Get the local hostname
	std::vector<string> result;
	unsigned long size=15*1024;
	MIB_IPADDRTABLE *ip_addr_table = (MIB_IPADDRTABLE*)malloc(size);

	DWORD get_result = GetIpAddrTable(ip_addr_table, &size, true);

	if( get_result != NO_ERROR )
	{
		const char *errorstr=0;
		switch( get_result )
		{
		case ERROR_INSUFFICIENT_BUFFER: errorstr = "insufficient buffer "; break;
		case ERROR_INVALID_PARAMETER: errorstr = "invalid parameter "; break;
		case ERROR_NOT_SUPPORTED: errorstr = "not supported "; break;
		default: errorstr = ""; break;
		}
		LOG_WRN("Looking up the own ip-address(es) failed: " << errorstr << "(" << get_result << ")")
	}
	else
	{
		IN_ADDR IPAddr;
		for (int i=0; i < (int) ip_addr_table->dwNumEntries; i++)
		{
	        //printf("\n\tInterface Index[%d]:\t%ld\n", i, ip_addr_table->table[i].dwIndex);
	        IPAddr.S_un.S_addr = (u_long) ip_addr_table->table[i].dwAddr;
			const char *buff = inet_ntoa(IPAddr);
	        //printf("\tIP Address[%d]:     \t%s\n", i, buff );
			result.push_back( buff );
		}
	}

	free(ip_addr_table);

	result.push_back("192.168.1.15");
	return result;
}
#else
std::vector<string> get_local_ip_addresses()
{	
	// Get the local hostname
	std::vector<string> result;

	// Get local IP address(es)
	struct ifaddrs *ifap = 0;
	if( getifaddrs( &ifap ) == 0 )
	{
		for(; ifap ; ifap = ifap->ifa_next)
		{
			struct sockaddr_in *inaddr = (struct sockaddr_in *)ifap->ifa_addr; 
			char buff[50];
			const char *out = inet_ntop(inaddr->sin_family, &(inaddr->sin_addr), buff, sizeof(buff));
			if( out )
			{
				result.push_back( buff );
			}
		}
		freeifaddrs( ifap );
	}
	else
	{
		LOG_WRN("Looking up the own ip-address(es) failed")
	}

	return result;
}
#endif
