/*

nquire-discover.cpp  - example implementation for the nquire discovery protocol

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

#include <sstream>
#include <iostream>
#include <string>
#include <map>
#include "misc.h"

using namespace std;

#define VERSION 0.2

// predefined discovery address and port
static const char discovery_addr[] = "239.255.255.250";
static const unsigned short discovery_port = 19200;

typedef std::map<std::string,std::string> Discovered_enquires;
static Discovered_enquires discovered_nquires;

std::string get_response_ip( std::string buf )
{
	static char addr_tag[] = "IP-Address: ";
	unsigned n = buf.find( addr_tag );
	string ip = "";
	if( n == string::npos )
	{
		cout << "WARNING: No IP-address found in response packet." << endl;
	}
	else
	{
		int b = n + strlen(addr_tag);
		int e = buf.find( "\n", b );
		ip = buf.substr( b, e-b );
	}
	return ip;
}

void show_help()
{
	cout << endl
		<< "nquire-discover [-h]|{[-n=n] [-s] [-r|+r] [-a]n\n\n"
		<< "VERSION = " << VERSION << "\n\n"
		<< "discover all nquires on a network\n\n"
		<< "Options:\n"
		<< " -h      show this text\n"
		<< " -n=n    retry sending discovery packet n-times\n"
		<< " -1      exit immediately after 1str found nquire\n"
		<< " -s      let system decide which port to send from\n"
		<< " -a      show all info of discovered nquires (default is only showing the ip)\n"
		<< "         and send RESPONSE-TO-SENDER-PORT discovery option\n"
		<< " -r      do not send RESPONSE-TO-SENDER-PORT discovery option\n"
		<< " +r      force use of RESPONSE-TO-SENDER-PORT discovery option\n"
		<< " -R      do not send RESPONSE-TO-SENDER-ADDRESS discovery option\n"
		<< " +R      force use of RESPONSE-TO-SENDER-ADDRESS discovery option\n"
		<< " -v=n    logging level 3=inf, 4=debug, 5=trace\n\n"
		<< "E.g.:  nquire-discover -n=2 -s\n\n"
		<< "Note: you won't receive the response packets when using\n"
		<< "option -s with -r because the response packet is sent to port 19200.\n"
		<< "Contrary, using option -r can be used without -s because the sender\n"
		<< "port is the default response port. But than you will also receive\n"
		<< "the discovery packet itself.\n"
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

int main(int argc, char * argv[]) {

	bool response_to_sender_port = false;
	bool no_response_to_sender_port = false;
	bool response_to_sender_address = false;
	bool no_response_to_sender_address = false;
	int n = 3;
	unsigned short port = discovery_port;
	bool exit_1rst = false;
	bool show_all = false;

	int i;
	for(i=1; i<argc; i++)
	{
		string opt=argv[i];
		if(	opt=="-h" || opt=="/h" ||
			opt=="-?" || opt=="/?" ||
			opt=="/h" || opt=="/H" ||
			opt=="-help" || opt=="/help" )
		{
			show_help();
			exit(0);
		}
		else if( opt=="-a" )
		{
			show_all = true;
		}
		else if( opt=="-s" )
		{
			// let system decide which port to use
			// for sending the CIT-DISCOVER-REQUEST packet
			// instead of the default port=19200
			port = 0;
			if( ! no_response_to_sender_port )
				response_to_sender_port = true;
		}
		else if( opt=="-1" )
		{
			// exit after first found nquire
			exit_1rst = true;
		}
		else if( strncmp(opt.c_str(),"-v=",3)==0 && (opt[3]=='3' || opt[3]=='4' || opt[3]=='5'))
		{
			// exit after first found nquire
			set_log_level( opt[3] - '0' );
		}
		else if( opt=="-r" )
		{
			// don't use CIT-DISCOVER-REQUEST option RESPONSE-TO-SENDER-PORT
			response_to_sender_port = false;
			no_response_to_sender_port = true;
		}
		else if( opt=="+r" )
		{
			// use CIT-DISCOVER-REQUEST option RESPONSE-TO-SENDER-PORT
			response_to_sender_port = true;
			no_response_to_sender_port = false;
		}
		else if( opt=="-R" )
		{
			// don't use CIT-DISCOVER-REQUEST option RESPONSE-TO-SENDER-ADDRESS
			response_to_sender_address = false;
			no_response_to_sender_address = true;
		}
		else if( opt=="+R" )
		{
			// use CIT-DISCOVER-REQUEST option RESPONSE-TO-SENDER-ADDRESS
			response_to_sender_address = true;
			no_response_to_sender_address = false;
		}
		else if( opt.compare(0, 3, "-n=" ) == 0 )
		{
			n = atoi( argv[i]+3 );
		}
		else if( opt.compare(0,5,"-log=")==0 )
		{
			string logfile = opt.substr(5);
			set_log_file( logfile );
		}
		else if ( opt.compare(0,3,"-l=")==0 )
		{
			set_log_level( atoi(opt.substr(3).c_str()) );
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

	int fd = socket(PF_INET, SOCK_DGRAM, 0); // udp
	if( fd == -1 )
	{
		cerr << "FATAL: socket() - " << strerror(errno) << endl;
		return -1;
	}
	//cout << "# Socket opened." << endl;

	// set socket options
#ifdef WIN32
	unsigned long sockflags = 1; // non-blocking
	ioctlsocket( fd, FIONBIO, &sockflags);
#else
	// The unix way:
	int f = fcntl(fd, F_GETFL);
	f |= O_NONBLOCK;
	fcntl(fd, F_SETFL, f);
#endif

	// allow broadcasts
	int valint = 1;
	int r;
	r = setsockopt(fd, SOL_SOCKET, SO_BROADCAST, (char *)&valint, sizeof valint);
	HANDLE_ERROR( r );
	r = setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (char *)&valint, sizeof valint);
	HANDLE_ERROR( r );

#ifndef WIN32
	{	LOG_DMP("Join multicast group");
		struct ip_mreq mreq;
		mreq.imr_interface.s_addr = htonl(INADDR_ANY);
		mreq.imr_multiaddr.s_addr = inet_addr(discovery_addr);
		//cout << "IP_ADD_MEMBERSHIP=" << IP_ADD_MEMBERSHIP << endl;
		r = setsockopt(fd, SOL_IP,     IP_ADD_MEMBERSHIP, (char*)&mreq, sizeof mreq);
		HANDLE_ERROR( r );
	}
#endif

	//cout << "# Flags set" << endl;

	// bind to port on any interface
	struct sockaddr_in sa_recv;
	memset(&sa_recv, 0, sizeof(sa_recv));
	sa_recv.sin_family = AF_INET;
	sa_recv.sin_addr.s_addr = htonl(INADDR_ANY);
	//sa_recv.sin_addr.s_addr = inet_addr(discovery_addr);
	// Specify port from which you want to send the discover request packet
	// Usually you want to let the system determine the sender port
	// Use port 0 for a system determined port:
	// When you want to receive the response on this port, specify discovery
	// option "RESPONSE-TO-SENDER-PORT" in the discovery message (nquire version >= 1.3)
	sa_recv.sin_port = htons(port);
	LOG_DMP("Bind receiving socket to "	<< sa_recv.sin_addr.s_addr << "." << port);

	//cout << "# Bind socket" << endl;
	int rr = bind(fd, (struct sockaddr *)&sa_recv, sizeof(sa_recv));
	if( rr<0 )
	{
		HANDLE_ERROR( errno );
		exit(-1);
	}
#ifdef WIN32
	{	LOG_DMP("Join multicast group")
		struct ip_mreq mreq;
		mreq.imr_interface.s_addr = htonl(INADDR_ANY);
		mreq.imr_multiaddr.s_addr = inet_addr(discovery_addr);
		LOG_DMP("IP_ADD_MEMBERSHIP=" << IP_ADD_MEMBERSHIP);
		r = setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char*)&mreq, sizeof mreq);
		HANDLE_ERROR( r );
	}
#endif

	LOG_DMP("Sending " << n << " discovery requests and wait 2 seconds for response packets...");

	while( n-- > 0 )
	{
		LOG_DMP("Send discover request");

		stringstream msg;
		msg << "CIT-DISCOVER-REQUEST" << endl << "Version:\t1";
		if( response_to_sender_port )
			msg << endl << "RESPONSE-TO-SENDER-PORT";
		if( response_to_sender_address )
			msg << endl << "RESPONSE-TO-SENDER-ADDRESS";

		// destination address spec:
		struct sockaddr_in sa_dest;
		memset(&sa_dest, 0, sizeof(sa_dest));
		sa_dest.sin_port = htons(discovery_port);
		sa_dest.sin_family = AF_INET;
		sa_dest.sin_addr.s_addr = inet_addr(discovery_addr);

		LOG_DMP("Sending CIT-DISCOVER-REQUEST to " << discovery_addr << "." << discovery_port);
		unsigned r = sendto(fd, msg.str().c_str(), msg.str().size(), 0, (struct sockaddr *)&sa_dest, sizeof(sa_dest));
		if( r!=msg.str().size() )
		{
			HANDLE_ERROR( r );
			exit(-1);
		}

		int rc=1;

		while (rc>0)
		{
			float time_to_wait = 2; // sec
			struct timeval tv;
			tv.tv_sec=(int)time_to_wait;    //SECOND
			tv.tv_usec=((int)(time_to_wait*1000000))%1000000; //USECOND

			fd_set readfd;
			FD_ZERO(&readfd);
			FD_SET(((unsigned)fd),&readfd);

			rc=select(fd+1,&readfd,NULL,NULL,&tv);

			if(rc>0)
			{
				char buf[1600];
				memset(buf,0,sizeof(buf));
				struct sockaddr_in from;
#ifdef WIN32
				int fromlen = sizeof(from);
#else
				socklen_t fromlen = sizeof(from);
#endif
				rc = recvfrom(fd,buf,sizeof(buf),0, (struct sockaddr*)(&from), &fromlen);
				HANDLE_ERROR( rc );
				std::string ipaddr =  inet_ntoa(from.sin_addr);
				LOG_DBG("message from " << ipaddr
						<< "." << ntohs(from.sin_port)
						<< " (" <<  rc << "):'" << buf << "'");

				if(strncmp("CIT-DISCOVER-RESPONSE",buf,strlen("CIT-DISCOVER-RESPONSE"))==0)
				{
					string ip = get_response_ip( buf );
					if( discovered_nquires.find( ip ) == discovered_nquires.end() )
					{
						discovered_nquires.insert( make_pair(ip, buf) );
						cout << ipaddr << endl; 
						if( show_all )
						{
							cout << buf << endl;
						}
						if( exit_1rst )
						{
							n=0;
							break;
						}
					}
					else
					{
						LOG_DMP("Received packet from already discovered nquire with ip " << ip);
					}
				}
				else
				{
					LOG_DMP("Ignoring unrecognized packet \"" << string(buf,rc) << "\"");
				}
			}
			else if( rc == 0 )
			{
				LOG_DMP("# timeout waiting for response packet");
			}
			else
				LOG_WRN("# error = " << rc );
		}
	}

	//cout << "# Ready" << endl;
#ifdef WIN32
	WSACleanup();
#endif
	return EXIT_SUCCESS;
}

