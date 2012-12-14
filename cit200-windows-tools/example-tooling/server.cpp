//
// upd-server.cpp
//
// Author: M.R. van dootingh
// Date: febr 5 2010
//
// This server listens to udp port 9000 for messages
// each message is expected to be a barcode.
//
// The barcode is used as a filename in the "data" directory
// The first line is the filename of the formatfile, the rest are content lines.
// The format file contains escape codes
//
//



/*****************************************************************************/

/*** upd-server.c                                                          ***/

/***                                                                       ***/

/*** Create a datagram server that waits for client messages (which it     ***/

/*** echoes back).                                                         ***/

/*****************************************************************************/

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

#include "misc.h"
#include "database.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

#include <string>
#include <iostream>
#include <sstream>
#include <algorithm>


using namespace std;

#define DEFAULT_PORT	9000
#define VERSION "0.3"

// the directory in which the barcode and format files should be located
string barcode_dir = ".";

Barcode_db the_barcode_db;

void show_help()
{
	cout << "nquire_server.exe [-h] | { [-log=file] [-d] [-p=nnnnn] [-db=dir] }" << endl << endl
		<< "VERSION = " << VERSION << endl << endl
		<< "This is a fully functional example implementation for an nquire server program." << endl
		<< "nquire_server.exe can function as a stand-alone database server and is" << endl
		<< "configurable by comandline options." << endl
		<< "It has a simple ini-file style database implementation that is seperated " << endl
		<< "into two files (also see option -db):" << endl
		<< "   formats.ini  - a file containing formats for sending to the nquires" << endl
		<< "   barcodes.ini - a file containing all barcodes and their 'tags'." << endl << endl
		<< "   -h|-help|/h/H  show this text" << endl
		<< "   -p=nnnnn       use port nnnnn to listen to instead 9000" << endl
		<< "                  for now, only udp communication is supported" << endl
		<< "   -db=dir        use directory dir instead of the current directory" << endl
		<< "                  looking for files formats.ini and barcodes.ini" << endl
		<< "   -log=file      write logging to 'file' instead of 'nquire-server.log'" << endl
		<< "                  use '-log=-' for logging to the screen" << endl
		<< "   -v=n           log verbosity: 3=info (default), 4=debug, 5=dump" << endl
		<< endl;
}


#define sep "# ----------------------------------------\n"

#ifdef WIN32
#define HANDLE_ERROR( errno ) \
	if(errno<0) cout << __FILE__ << ":" << __LINE__ << " WSAGetLastError=" << WSAGetLastError() << endl
#else
#define HANDLE_ERROR( errno ) \
	if(errno<0) cout << __FILE__ << ":" << __LINE__ << " Errno=" << errno << " - " << strerror(errno) << endl
#endif


int main(int argc, char *argv[])
{

#ifdef WIN32
	int rr;
	WSADATA data;
	rr = WSAStartup( MAKEWORD( 1, 1 ), &data );
	if ( rr != 0 ) {
		printf("No usable winsock.dll found.");
		return -1;
	}
#endif

	int port=DEFAULT_PORT;
	string db_dir(".");

	std::string logfile = "nquire-server.log";

	// interprete commandline
	for(int i=1; i<argc; i++)
	{
		string opt=argv[i];
		if( opt=="-h" || opt=="/h" || opt=="/H" || opt=="-help" || opt=="/help")
		{
			show_help();
			return 0;
		}
		else if( opt.compare(0,3,"-p=")==0 )
		{
			port = atoi(opt.substr(3).c_str());
		}
		else if( opt.compare(0,4,"-db=")==0 )
		{
			db_dir = opt.substr(4);
			LOG_DBG("db_dir=\"" << db_dir << "\"");
		}
		else if( opt.compare(0,5,"-log=")==0 )
		{
			logfile = opt.substr(5);
		}
		else if ( opt.compare(0,3,"-v=")==0 )
		{
			set_log_level( atoi(opt.substr(3).c_str()) );
		}
		else
		{
			cerr << "ERROR: unkown option \"" << opt << "\"" << endl << endl;
			show_help();
			return -1;
		}
	}


	std::vector<string> my_addresses = get_local_ip_addresses();

	set_log_file( logfile );
	if (logfile != "-")
		cout << "Logging to " << logfile << endl;
	LOG_INF( "Using database directory " << db_dir );
	LOG_INF( "Using UDP port " << port );

	int sd = -1;
	try
	{
		the_barcode_db.load(db_dir);
	
		sd = socket(PF_INET, SOCK_DGRAM, 0);
		HANDLE_ERROR( sd );

		// bind to port on any interface
		struct sockaddr_in sa_recv;
		memset(&sa_recv, 0, sizeof(sa_recv));
		sa_recv.sin_family = AF_INET;
		sa_recv.sin_addr.s_addr = htonl(INADDR_ANY);
		sa_recv.sin_port = htons(port);
		LOG_DBG("Bind receiving socket to " << sa_recv.sin_addr.s_addr << "." << port );

		//cout << "# Bind socket" << endl;
		int rr = bind(sd, (struct sockaddr *)&sa_recv, sizeof(sa_recv));
		if( rr<0 )
		{
			HANDLE_ERROR( errno );
			exit(-1);
		}

		for(;;)
		{

			char buf[1600];
			memset(buf,0,sizeof(buf));
			struct sockaddr_in from;
			memset(&from,0,sizeof(from));
#ifdef WIN32
			int fromlen = sizeof(from);
#else
			socklen_t fromlen = sizeof(from);
#endif
			// from is filled with the address of the nquire
			int bytes = recvfrom(sd,buf,sizeof(buf),0, (struct sockaddr*)(&from), &fromlen);
			HANDLE_ERROR( bytes );
			string nquire(inet_ntoa(from.sin_addr));

			if( find( my_addresses.begin(), my_addresses.end(), nquire ) != my_addresses.end() )
			{
				LOG_DMP( "msg from " << nquire << "." << ntohs(from.sin_port)
						<< " (#" <<  bytes << " bytes):'" << bytes_to_text(string(buf,bytes)) << "'");
			}
			else if( bytes > 0 )
			{
				LOG_DMP( "msg from " << nquire << "." << ntohs(from.sin_port)
						<< " (#" <<  bytes << " bytes):'" << bytes_to_text(string(buf,bytes)) << "'");

				// strip trailing '\n'
				if( buf[strlen(buf)-1] == '\n' )
					bytes--;
				string barcode( buf, bytes );

				try
				{
					LOG_INF("Received barcode \"" << barcode << "\"");
					// (re)load when necessary:
					the_barcode_db.load( db_dir );

					// lookup the barcode and merge with format
					string answer = the_barcode_db.lookup( barcode );

					// transform escape codes
					string bin_answer = text_to_bytes( answer );

					// destination address spec:
					struct sockaddr_in sa_dest = from;
					sa_dest.sin_port = htons(port);

					LOG_DBG("Sending: \"" << answer << "\"" << " to " << nquire << "." << port);
					sendto(sd, bin_answer.c_str(), bin_answer.size(), 0, (struct sockaddr*)&sa_dest, sizeof(sa_dest));
				}
				catch(string msg)
				{
					cerr << msg << endl;
				}
			}
			else
			{
				LOG_WRN("Empty message received from " << nquire);
			}
		}
	}
	catch(string errmsg)
	{
		cerr << errmsg << endl;
		if(sd>=0) close(sd);
	}
#ifdef WIN32
	WSACleanup();
#endif
	return 0;

}

