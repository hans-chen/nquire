/*

testserver.cpp  - simple testserver for auto-testing the application

Messages received from local port 9101 are send to the nquire using tcp
Messages received from local port 9000 are send to the nquire using upd

It connects to the nquire using tcp and listens to udp. All received data is 
echo'ed to to stdout.

Author: M.R. van Dootingh

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/select.h>
#include <fcntl.h>
#include <netdb.h>
#include <errno.h>
#include <assert.h>
//#include <sys/time.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <poll.h>
#include <time.h>

#include <sstream>
#include <iostream>
#include <string>
#include <ios>
#include <iomanip>
#include <map>
#include <set>
#include <vector>
#include "misc.h"

using namespace std;

#define VERSION 0.1

// predefined discovery address and port
static const char discovery_addr[] = "239.255.255.250";
static const unsigned short discovery_port = 19200;

static const unsigned short nquire_udp_port = 9000;
static const unsigned short nquire_tcp_port = 9101;

static const unsigned short local_udp_port = 9000;
static const unsigned short local_tcp_port = 9101;

void show_help()
{
	cout << endl
		<< "testserver [-v=][--ip=n.n.n.n][-d][--connect_ext][--difftime]" << endl << endl
		<< "This server acts as a kind of proxy between the nquire and a test-program" << endl
		<< endl
		<< "It serves the following goals:" << endl
		<< "  - preventing frequest connect and disconnects on the nquire" << endl
		<< "  - a simple way to catch ALL trafiic from and to the nquire" << endl
		<< "  - standardized logging of all traffic from and to the nquire" << endl
		<< "  - a way to extend this without having to change all testcases." << endl
		<< endl 
		<< "The server will:" << endl
		<< "  - connect to the nquire using 192.168.1.200 or another specified address." << endl
		<< "  - use port 9000 for udp and 9101 for tcp connection to the nquire" << endl
		<< "  - listen to all TCP and UDP interfaces of the nquire for traffic or incomming connects." << endl
		<< "  - not connect to the nquire using ftp or http (use curl to test this)." << endl
		<< "  - pass reply's through to the last client connection issuing a send to the nquire (tcp only)" << endl
		<< endl
		<< "Options" << endl
		<< "  -d            : deomonize" << endl
		<< "  -v=n          : set logging level (3=INF, 4=DEBUG, 5=DUMP)" << endl
		<< "  --ip	        : the ip address of the nquire (default 192.168.1.200)" << endl
		<< "  --connect_ext : try to establish an extra tcp connection for catching events" << endl
		<< "  --difftime    : show difftime for incomming msg counting from the last send msg" << endl
		<< endl
		<< "Examples:" << endl
		<< "Sending clearscreen and display 'hello' using the TCP connection: " << endl
		<< "echo -en '\\x1b\\x24\\x1b\\x2e\\x34hello\\x03' | nc localhost 9101" << endl
		<< endl;
}

static void setnonblock( int fd )
{
	int f = fcntl(fd, F_GETFL);
	f |= O_NONBLOCK;
	fcntl(fd, F_SETFL, f);
}

class to_escapes
{
public:
    explicit to_escapes(const unsigned char* b, unsigned n):
    	b(b),
    	n(n)
    {
    	LOG_DBG("to_escapes: " << n);
    }
	
	friend std::ostream& operator<<(std::ostream &out, const to_escapes& s);
private:
	const unsigned char *b;
	unsigned n;
};


std::ostream& operator<<(std::ostream &out, const to_escapes& s)
{
	bool after_esc = false;
	for(int i=0; i<s.n; i++)
	{
		unsigned char c = s.b[i];
		if( after_esc )
		{
			out << "\\x" << hex << setfill('0') << setw(2) << (unsigned)c << dec;
			after_esc = false;
		}
		else if( c>=0x20 && c<0x80 )
			out << c;
		else 
			switch( c )
			{
			case '\n': out << "\\n"; break;
			case '\r': out << "\\r"; break;
			case '\t': out << "\\t"; break;
			case '\\': out << "\\\\"; break;
			case '\x1b': out << "\\e"; after_esc = true; break;
			default: out << "\\x" << hex << setfill('0') << setw(2) << (unsigned)c << dec; break;
			}
	}
	return out;
}

// peek the origin of a message in a UDP socket
static const string peek_origin( int fd )
{
	static char recv_ip[100];
	struct sockaddr source;
	memset(&source,0,sizeof(source));
	struct msghdr msg;
	memset(&msg,0,sizeof(msg));
	
	msg.msg_name = &source;
	msg.msg_namelen = sizeof(source)-1;
	
	int r = recvmsg(fd, &msg, MSG_DONTWAIT | MSG_PEEK);
	if(r<0)
	{
		LOG_WRN("recv error: " << strerror(errno))
		return 0;
	}	
	else
	{
		struct sockaddr_in *sin = (struct sockaddr_in *)&source;
		inet_ntop(AF_INET, &sin->sin_addr, recv_ip, sizeof(recv_ip));
		LOG_DBG("Received from " <<  recv_ip);
		stringstream s(recv_ip);
		s << "." << ntohs(sin->sin_port);
		return s.str();
	}
}


static int open_udp( unsigned port )
{
	int r;

	int fd = socket(AF_INET, SOCK_DGRAM, 0);
	if( fd == -1 )
		LOG_FTL( "local udp socket() - " << strerror(errno) );
	setnonblock( fd );

	int reuse_addr = 1;
	r = setsockopt( fd, SOL_SOCKET, SO_REUSEADDR, &reuse_addr, sizeof(reuse_addr) );
	if( r < 0 )
		LOG_FTL("setsockopt: " << strerror(errno));

	// bind to port on local pc:
	struct sockaddr_in sa_recv;
	memset(&sa_recv, 0, sizeof(sa_recv));
	sa_recv.sin_family = AF_INET;
	sa_recv.sin_addr.s_addr = htonl(INADDR_ANY);
	sa_recv.sin_port = htons(port);
	r = bind(fd, (struct sockaddr *)&sa_recv, sizeof(sa_recv));
	if( r<0 )
		LOG_FTL("bind " << port << " failed: " << strerror(errno));
	
	return fd;
}

static int open_tcp_listen( unsigned port )
{
	int r;

	int fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if( fd == -1 )
		LOG_FTL( "local udp socket() - " << strerror(errno) );
	setnonblock( fd );

	int reuse_addr = 1;
	r = setsockopt( fd, SOL_SOCKET, SO_REUSEADDR, &reuse_addr, sizeof(reuse_addr) );
	if( r < 0 )
		LOG_FTL("setsockopt: " << strerror(errno));

	// bind to port on local pc:
	struct sockaddr_in sa_recv;
	memset(&sa_recv, 0, sizeof(sa_recv));
	sa_recv.sin_family = AF_INET;
	sa_recv.sin_addr.s_addr = htonl(INADDR_ANY);
	sa_recv.sin_port = htons(port);
	r = bind(fd, (struct sockaddr *)&sa_recv, sizeof(sa_recv));
	if( r<0 )
		LOG_FTL("bind " << port << " failed: " << strerror(errno));
		
	  /* Listen on the server socket */
	if (listen(fd, 4) < 0)
		LOG_FTL("listen " << port << " failed: " << strerror(errno));
           
	return fd;
}

int open_tcp_connect( const char* ip, int port )
{
	// try to connect to the nquire:
	int fd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
	if( fd < 0 )
	{
		LOG_FTL("Could not create TCP client socket: " << strerror(errno));
	}
	else
	{
		int reuse_addr = 1;
		int r;

		r = setsockopt( fd, SOL_SOCKET, SO_REUSEADDR, &reuse_addr, sizeof(reuse_addr) );
		if( r < 0 )
			LOG_FTL("setsockopt: " << strerror(errno));

		struct sockaddr_in nquire;
		memset(&nquire, 0, sizeof(nquire));
		nquire.sin_family = AF_INET;
		nquire.sin_addr.s_addr = inet_addr(ip);
		nquire.sin_port = htons(port);
		r = connect(fd, (struct sockaddr *) &nquire, sizeof(nquire));
		if( r<0 ) // TODO: exclude 'busy' error due to async sockets
		{
			LOG_DMP("Could not connect to Nquire. Better luck next time.");
			close(fd);
			fd = -1;
		}
		else
			LOG_DBG("Successfully connected to nquire");
	}

	return fd;
}

static double hirestime()
{
	struct timespec tv;
	double now;

	clock_gettime(CLOCK_MONOTONIC, &tv);

	now = tv.tv_sec + (tv.tv_nsec) / 1.0E9;
	
	return now;
}

static string difftimestr(bool show_difftime, double t_last_msg)
{
	if( show_difftime )
	{
		int dt = (int)(hirestime() - t_last_msg + 0.5);
		stringstream s;
		s << " dt=" << dt;
		return s.str();
	}
	return "";
}

int main(int argc, char * argv[]) 
{
	const char *nquire_ip = "192.168.1.200";
	bool deamonize = false;
	bool try_connect_tcp_connect_extra = false;
	bool show_difftime = false;
	
	for(int i=1; i<argc; i++)
	{
		string opt=argv[i];
		if(	opt=="-h" || opt=="/h" ||
			opt=="-?" || opt=="/?" ||
			opt=="/h" || opt=="/H" ||
			opt=="-help" || opt=="--help" || opt=="/help" )
		{
			show_help();
			exit(0);
		}
		else if( strcmp(opt.c_str(),"-d") == 0 )
		{
			deamonize = true;
		}
		else if( strncmp(opt.c_str(),"-v=",3)==0 && (opt[3]=='3' || opt[3]=='4' || opt[3]=='5') )
		{
			set_log_level( opt[3] - '0' );
		}
		else if( strncmp(opt.c_str(),"--ip=",5)==0 )
		{
			nquire_ip = argv[i]+5;
		}
		else if( strncmp(opt.c_str(),"--connect_ext",15)==0 )
		{
			try_connect_tcp_connect_extra = true;
		}
		else if( strncmp(opt.c_str(),"--difftime",10)==0 )
		{
			show_difftime = true;
		}
		else
		{
			cerr << "ERROR: unrecognized option '" << opt << "'" << endl << endl;
			show_help();
			exit(-1);
		}
	}

	// ==============================
	// preparations

	
	// ---------------------------
	// local udp listening socket:
	int fd_udp_local = open_udp( local_udp_port );
	int fd_udp_send_sock = open_udp( 0 );

	// local tcp listening socket:
	int fd_tcp_listen = open_tcp_listen( local_tcp_port );

	int fd_tcp_connect_cmd = -1;
	int fd_tcp_connect_evt = -1;
	double t_last_msg = hirestime();

	// the fd of the socket through which the last command was givven
	int last_cmd_socket_fd = -1;

	if( deamonize )
	{
		// deamonize when all connections are innitialized...
		int pid = fork();
		if( pid == -1 )
		{
			LOG_FTL("Could not deamonize");
		}
		if( pid != 0 )
		{
			LOG_DBG("Deamon process id = " << pid);
			sleep(1);
			return 0;
		}
	}


	// ====================
	// Now the actual work:
	LOG_DBG("starting loop");

	int rc;
	set<int> accepted_clients;
	
	do
	{
		if( fd_tcp_connect_cmd < 0 )
			fd_tcp_connect_cmd = open_tcp_connect( nquire_ip, nquire_tcp_port );

		if( fd_tcp_connect_evt < 0 and try_connect_tcp_connect_extra )
			fd_tcp_connect_evt = open_tcp_connect( nquire_ip, nquire_tcp_port );
		
		vector<struct pollfd> fds;

		fds.push_back( (struct pollfd){ fd_udp_local, POLLIN, 0 } );
		fds.push_back( (struct pollfd){ fd_udp_send_sock, POLLIN, 0 } );
		fds.push_back( (struct pollfd){ fd_tcp_listen, POLLIN, 0 } );

		// and add opened client sockets:
		for(set<int>::iterator it=accepted_clients.begin(); it!=accepted_clients.end(); it++)
			fds.push_back( (struct pollfd){ *it, POLLIN, 0 } );

		if( fd_tcp_connect_cmd>=0 )
			fds.push_back( (struct pollfd){ fd_tcp_connect_cmd, POLLIN, 0 } );

		if( fd_tcp_connect_evt>=0 )
			fds.push_back( (struct pollfd){ fd_tcp_connect_evt, POLLIN, 0 } );

		rc = poll( &fds.front(), fds.size(), 10000 );
		
		LOG_DMP("pollthrough")
		if( rc>0 )
		{
			LOG_DMP("rc=" << rc)
			for( vector<struct pollfd>::iterator fd = fds.begin(); fd != fds.end(); fd++ )
			{
				if( fd->revents == 0 )
				{
					// nothing to do
				}
				else if( fd->fd == fd_udp_local )
				{
					struct sockaddr source;
					memset(&source,0,sizeof(source));
					struct msghdr msg;
					memset(&msg,0,sizeof(msg));
					
					msg.msg_name = &source;
					msg.msg_namelen = sizeof(source)-1;
					
					int r = recvmsg(fd->fd, &msg, MSG_DONTWAIT | MSG_PEEK);
					if(r<0)
					{
						if( errno != EAGAIN )
							LOG_WRN("recv error: " << strerror(errno));
					}
					else
					{
						char recv_ip[100];
						inet_ntop(AF_INET, &((struct sockaddr_in *)&source)->sin_addr, recv_ip, sizeof(recv_ip));

						LOG_DBG("Received from " <<  recv_ip);
						unsigned char buff[2048];
						int r_recv = recv( fd->fd, buff, sizeof(buff), MSG_DONTWAIT);
						if( r_recv<0 )
							LOG_FTL( "Receive error from " << recv_ip << ": " << strerror(errno))
						int nbuff = r_recv;

						if( strcmp(recv_ip,nquire_ip)==0)
						{
							cout << "<" << difftimestr(show_difftime,t_last_msg) << " UDP event (n=" << r_recv << "): \"" << to_escapes(buff, nbuff) << "\"" << endl;
						}
						else
						{
							// so we can assume it is a command that is to be send to the nquire:
							cout << ">" << difftimestr(show_difftime,t_last_msg) << " UDP (n=" << nbuff << "): \"" << to_escapes(buff, nbuff) << "\"" << endl;
							struct sockaddr_in sa_dest;
							memset(&sa_dest, 0, sizeof(sa_dest));
							sa_dest.sin_port = htons(nquire_udp_port);
							sa_dest.sin_family = AF_INET;
							sa_dest.sin_addr.s_addr = inet_addr(nquire_ip);
							unsigned r_sendto = sendto(fd_udp_send_sock, buff,nbuff, 0, (struct sockaddr *)&sa_dest, sizeof(sa_dest));
							t_last_msg = hirestime();
							
							// and disable the tcp command client
							last_cmd_socket_fd = -1;

							if( r<0 )
								LOG_FTL( "Sendto error: " << strerror(errno));
						}
					}
				}
				else if( fd->fd == fd_udp_send_sock )
				{
					LOG_DBG("on udp send socket");

					string org = peek_origin( fd->fd );
					unsigned char buff[2048];
					int r_recv = recv( fd->fd, buff, sizeof(buff), MSG_DONTWAIT);

					LOG_DBG("Received data from " << org);
					
					cout << "<" << difftimestr(show_difftime,t_last_msg) << " UDP cmd (n=" << r_recv << "): \"" << to_escapes(buff, r_recv) << "\"" << endl;
				}
				else if( fd->fd == fd_tcp_listen )
				{
					LOG_DBG("Received tcp listen event (fd->revents=" << fd->revents << ")");
					struct sockaddr_in client;
					unsigned int clientlen = sizeof(client);

					int fd_client = accept(fd->fd, (struct sockaddr *) &client, &clientlen);
					if( fd_client < 0 )
					{
						if( errno != EAGAIN )
							LOG_FTL( "Accept error: " << strerror(errno));
					}
					else
					{
						LOG_DBG("Accepted client");
						accepted_clients.insert(fd_client);
					}
				}
				else if( accepted_clients.find(fd->fd) != accepted_clients.end() )
				{
					LOG_DBG("on tcp client socket");

					string org = peek_origin( fd->fd );

					unsigned char buff[2048];
					memset(buff,0,sizeof(buff));
					int r_recv = recv( fd->fd, buff, sizeof(buff), MSG_DONTWAIT);

					if( r_recv == 0 )
					{
						// client closed connection
						if( org == nquire_ip )
							cout << "<" << difftimestr(show_difftime,t_last_msg) << " hangup" << endl;
						else
							LOG_DBG("TCP hangup");
						close(fd->fd);
						accepted_clients.erase (accepted_clients.find(fd->fd));
						if( last_cmd_socket_fd == fd->fd )
						{
							LOG_DBG("Remove last_cmd_socket_fd");
							last_cmd_socket_fd = -1;
						}
					}
					else
					{
						int nbuff = r_recv;
						if( org == nquire_ip )
						{
							cout << "<" << difftimestr(show_difftime,t_last_msg) << " TCP event (n=" << nbuff << "): \"" << to_escapes(buff, nbuff) << "\"" << endl;
						}
						else 
						{
							cout << ">" << difftimestr(show_difftime,t_last_msg) << " TCP (n=" << nbuff << "): \"" << to_escapes(buff, nbuff) << "\"";
							if( fd_tcp_connect_cmd != -1 )
							{
								cout << endl;
								int r_send = send( fd_tcp_connect_cmd, buff, nbuff, 0 );
								if( r_send < 0 )
									LOG_FTL("send to nquire failed: " << strerror(errno))
								
								last_cmd_socket_fd = fd->fd;
								t_last_msg = hirestime();
							}
							else
							{
								cout << " ==> FAILED" << endl;
								LOG_WRN("No TCP connection to send the command to.")
							}
						}
					}
				}
				else if( fd->fd == fd_tcp_connect_cmd || fd->fd == fd_tcp_connect_evt)
				{
					LOG_DBG("on tcp nquire socket");

					const char *src = fd->fd == fd_tcp_connect_cmd ? "cmd" : "evt";
					
					unsigned char buff[2048];
					memset(buff,0,sizeof(buff));
					int r_recv = recv( fd->fd, buff, sizeof(buff), MSG_DONTWAIT);

					if( r_recv == 0 )
					{
						// client closed connection
						close(fd->fd);
						cout << "<" << difftimestr(show_difftime,t_last_msg) << " " << src << " hangup" << endl;
						if( fd->fd == fd_tcp_connect_cmd )
							fd_tcp_connect_cmd = -1;
						else if( fd->fd == fd_tcp_connect_evt )
							fd_tcp_connect_evt = -1;
						else
							LOG_FTL("Unknown fd")
					}
					else
					{
						unsigned nbuff = r_recv;
						cout << "<" << difftimestr(show_difftime,t_last_msg) << " TCP " << src << " (n=" << nbuff << "): \"" << to_escapes(buff, nbuff) << "\"" << endl;
						if( last_cmd_socket_fd != -1 )
						{
							LOG_DBG("Also pass through to command client");
							// pass it through when the client that gave the command is still waiting
							int r_send = send( last_cmd_socket_fd, buff, nbuff, 0 );
							if( r_send < 0 )
								LOG_FTL("Send reply to waiting client failed: " << strerror(errno));
						}
						else
							LOG_DBG("No client to send to reply to");
					}
				}
				else
					LOG_FTL("Unkown fd")
			}
		}
	}
	while (rc>=0);

	close(fd_udp_local);
	LOG_FTL("poll failed: " << errno << "(" << strerror(errno) << ")");

	return 0;
}

