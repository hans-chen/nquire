#include <sys/socket.h>
#include <netdb.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <resolv.h>
#include <arpa/nameser.h>
#include <arpa/inet.h>
#include <netinet/in.h>

int main( int argc, char *argv[] )
{
	const char *node = argv[1];
	struct addrinfo hints;
	memset( &hints, 0, sizeof(hints) );
	hints.ai_family = AF_INET;
	
	struct addrinfo * result;
	int error = getaddrinfo( node, 0, &hints, &result );
	if( error != 0 )
		return 1;

	struct addrinfo *res;
	int addr_counter = 0;
	
	printf("%s", node);
	for( res = result; res != 0; res = res->ai_next )
	{
		// only display the address when it is unique
		struct addrinfo *fres;
		for( fres = result; fres != res && memcmp(fres->ai_addr,res->ai_addr,sizeof(struct sockaddr_in)) != 0; fres = fres->ai_next )
		{}
		if( fres == res )
		{
			char s[INET_ADDRSTRLEN];
			struct sockaddr_in *sa = (struct sockaddr_in*)res->ai_addr;
			inet_ntop(sa->sin_family, &sa->sin_addr, s, sizeof(s));
			addr_counter++;
		
			printf(" %s", s);
		}
	}
	freeaddrinfo( result );
	fflush(stdout);
	return 0;
}
