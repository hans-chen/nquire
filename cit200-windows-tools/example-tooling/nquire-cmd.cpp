/*

nquire-cmd.cpp  - send a command to the nquire device

This is a demo tool for how to communicate escape commands with the nquire device.

Author: M.R. van Dootingh

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/select.h>
#include <fcntl.h>
#include <netdb.h>
#endif
//#include <io.h>
#include <errno.h>
#include <assert.h>
#include <sys/time.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <time.h>

#include <sstream>
#include <iostream>
#include <string>
#include <map>
#include "misc.h"

using namespace std;

#define VERSION 0.1

void show_help()
{
	cout << endl
		<< "nquire-cmd [-h]|{[-v=3|4|5] [-logfile={'-'|filename}] [-ip=addr] [-port=num] -msg=\"<command>\"" << endl << endl
		<< "VERSION = " << VERSION << endl << endl
		<< "Send a command to an nquire device (using tcp)" << endl << endl
		<< "Options:" << endl
		<< " -h          show this text" << endl
		<< " -log=f      set log file. Default is stdout." << endl
		<< " -v=n        set logging verbosity level: 3=info (DEFAULT), 4=debug, 5=dump" << endl
		<< " -ip=addr    the ip address of the nquire (default: 192.168.1.200)" << endl
		<< " -port=num   set the tcp listening port of the nquire (default: 9101)" << endl
		<< " -answer=n   read n response lines (default: 0)" << endl
		<< " -msg=cmd    the command to be send to the nquire (use \\xnn) " << endl
		<< endl
		<< "E.g. request firmware version:" << endl
		<< endl
		<< "nquire-cmd \'-msg=\\e\\x5f\' -answer=1 " << endl
		<< endl;
}

#define sep "# ----------------------------------------\n"

#ifdef WIN32
#define HANDLE_ERROR( errno ) \
	if(errno<0) cerr << __FILE__ << ":" << __LINE__ << " WSAGetLastError=" << WSAGetLastError() << endl
#else
#define HANDLE_ERROR( errno ) \
	if(errno<0) cerr << __FILE__ << ":" << __LINE__ << " Errno=" << errno << " - " << strerror(errno) << endl
#endif

int main(int argc, char * argv[])
{
	// predefined discovery address and port
	static string addr = "192.168.1.200";
	static unsigned short port = 9101;
	string fname = "-";
	string msg;
	int answer_lines = 0;

	int i;
	for(i=1; i<argc; i++)
	{
		string opt=argv[i];
		if(	opt=="-h" || opt=="/h" ||
			opt=="-?" || opt=="/?" ||
			opt=="-help" || opt=="/help" )
		{
			show_help();
			exit(0);
		}
		else if( opt.compare(0,9,"-logfile=")==0 )
		{
			string logfile = opt.substr(9);
			set_log_file( logfile );
		}
		else if ( opt.compare(0,3,"-v=")==0 )
		{
			set_log_level( atoi(opt.substr(3).c_str()) );
		}
		else if ( opt.compare(0,4,"-ip=")==0 )
		{
			addr = opt.substr(4).c_str();
		}
		else if ( opt.compare(0,6,"-port=")==0 )
		{
			port = atoi(opt.substr(6).c_str());
		}
		else if ( opt.compare(0,8,"-answer=")==0 )
		{
			answer_lines = atoi(opt.substr(8).c_str());
		}
		else if ( opt.compare(0,5,"-msg=")==0 )
		{
			msg = msg + opt.substr(5).c_str();
		}
		else
		{
			cerr << "ERROR: unrecognized option '" << opt << "'" << endl << endl;
			show_help();
			exit(-1);
		}
	}

#ifdef WIN32
	WSADATA data;
	int err = WSAStartup( MAKEWORD( 1, 1 ), &data );
	if ( err != 0 ) {
	    printf("No useable winsock.dll found.");
	    return -1;
	}
#endif

	int sockfd = socket(PF_INET, SOCK_STREAM, 0); // udp
	if( sockfd == -1 )
		LOG_FTL( "socket() - " << strerror(errno) );

	struct hostent *server = gethostbyname(addr.c_str());
    if (server == NULL) {
        fprintf(stderr,"ERROR, no such host\n");
        exit(0);
    }

    struct sockaddr_in serv_addr;

    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    memcpy(&serv_addr.sin_addr.s_addr, server->h_addr, server->h_length);
    serv_addr.sin_port = htons(port);

    /* Now connect to the server */
    if (connect(sockfd, (const sockaddr*)&serv_addr, sizeof(serv_addr)) < 0)
    {
         perror("ERROR connecting");
         exit(1);
    }

    LOG_DBG("Sending message:\"" << msg << "\"");
    string binmsg = text_to_bytes( msg );
    LOG_DBG("binmsg.len=" << binmsg.size());
    int n = send(sockfd, binmsg.c_str(), binmsg.size(),0);
	if (n < 0)
	{
		 perror("ERROR writing to socket");
		 exit(1);
	}

	// now receive 1 line of data:
	char rbuf;
	while( answer_lines>0 && recv(sockfd,&rbuf,1,0) == 1 )
	{
		if( rbuf == '\n')
			answer_lines--;
		printf("%c", rbuf);
	}

	LOG_DBG("# Ready");
#ifdef WIN32
	WSACleanup();
#endif
	return EXIT_SUCCESS;
}

