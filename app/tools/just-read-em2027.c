/*
 * just-read-em2027.c - test to read the em2027 each time it spawns data
 *
 * This is meant to be able to do an endurance test for the em2027
 * Usage: It is to be executed on the nquire, after which a barcode is shown 
 *        again an again (eg each second) When this done for about 2 days it is
 *        assumed that there is no bug in the em2027
 *
 */


#include <assert.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

const static char dev_scanner[] = "/dev/scanner";


static const char SCANNER_CMD_SAVE[]              = "0000160";
static const char SCANNER_CMD_SET_DEFAULTS[]      = "0001000";
static const char SCANNER_ALLOW_READ_BATCH_CODE[] = "0001110";
static const char SCANNER_CMD_SET_STOP_SUFFIX[]     = "0310000=0xFF";
static const char SCANNER_CMD_ENABLE_STOP_SUFFIX[] = "0309010";
static const char SCANNER_CMD_AUTO_SCAN[]         = "0302010";
static const char SCANNER_CMD_CODE_ID_ON[]        = "0307010";
static const char SCANNER_CMD_1D_DISABLE[]        = "0001030";
static const char SCANNER_CMD_1D_ENABLE[]         = "0001040";
static const char SCANNER_CMD_2D_DISABLE[]        = "0001050";
static const char SCANNER_CMD_2D_ENABLE[]         = "0001060";
static const char SCANNER_CMD_GET_INFO[]          = "0003000";

static const char SCANNER_CMD_ILLUMINATION_WINK[] = "0200000";
static const char SCANNER_CMD_ILLUMINATION_ON[]   = "0200010";
static const char SCANNER_CMD_ILLUMINATION_OFF[]  = "0200020";
	
static const char SCANNER_CMD_AIM_WINK[]          = "0201000";
static const char SCANNER_CMD_AIM_ON[]            = "0201010";
static const char SCANNER_CMD_AIM_SMART[]         = "0201030";

static const char SCANNER_CMD_SENSITIVITY_LOW[]   = "0312000";
static const char SCANNER_CMD_SENSITIVITY_NORMAL[]= "0312010";
static const char SCANNER_CMD_SENSITIVITY_HIGH[]  = "0312020";

static const char SCANNER_CMD_CONSTRAIN_MULTI_ON[]   = "0313010";
static const char SCANNER_CMD_CONSTRAIN_MULTI_SEMI[] = "0313030";
static const char SCANNER_CMD_CONSTRAIN_MULTI_ALL[]  = "0313020";

int em2027_read_until_ack( int f, char* buf, int bufsize )
{
	//printf("DEBUG: Read until ack...\n");
	int i=0;
	do
	{
		if( read( f, buf+i, 1 ) == 1 )
		{
			if( buf[i] == '\x06' )
			{
				buf[i] = 0;
				return i;
			}
			//printf("DEBUG: c = %c\n", buf[i] );
			i++;
		}
		else		
			usleep(1000);
	}
	while( i < bufsize-1 );
	assert( 0 );
	return 0;
}

void  em2027_flush( int f )
{
	//printf("DEBUG: em2027_flush...\n");
	int i = 100;
	printf("Flushed: \"");
	do
	{
		char c;
		if( read( f, &c, 1 ) == 1 )
		{
			i = 100;
			printf("%c", c );
		}
		else		
		{
			usleep(1000);
			i--;
		}
	}
	while( i>0 );
	printf("\"\n");
}


int em2027_cmd( int f, const char* cmd, char* rcv_buf, int buf_size )
{
	// write command:
	char cmd_buf[110];
	sprintf( cmd_buf,"NLS%s;", cmd );
	printf("Send: \"%s\"\n", cmd);
	write( f, cmd_buf, strlen(cmd_buf) );
	
	// read answer
	int n = em2027_read_until_ack( f, rcv_buf, buf_size );
	if( n == 0 )
		printf("Received: ACK\n");	
	else
		printf("Received: \"%s\"\n", rcv_buf);
		
	return n;
}



void em2027_ping( int f )
{	
	printf("Ping scanner\n");

	em2027_flush( f );

	write(f, "?", 1);
	char buf[1];
	while( read( f, buf, 1 ) != 1 )
	{
		usleep(1000);
	};
	assert( buf[0] == '!' );
	
	printf("Scanner pinged successfully\n");
}


void em2027_disable( int f )
{
	printf("Disabling scanner\n");
	write(f, "\x1b""0", 2);
	char buf[100];
	em2027_read_until_ack( f, buf, 100 );
	printf("Success disabling scanner\n");
}


void eme2027_read_version_info( int f )
{
	printf("Requesting scanner version info\n");
	char buf[2000];
	em2027_cmd( f, SCANNER_CMD_GET_INFO, buf, sizeof(buf) );
	printf("em2027 version info = %s\n", buf);
}


void em2027_set_defaults( int f )
{
	printf("Set em2027 defaults\n");

	char buf[512];
	em2027_cmd(f, SCANNER_CMD_SET_DEFAULTS, buf, sizeof(buf) );
	
	printf("Success Setting em2027 defaults\n");
}

void em2027_configure( int f, const char *conf[] )
{
	printf("Configuring scanner\n");
	char buf[100];
	em2027_cmd(f, SCANNER_ALLOW_READ_BATCH_CODE, buf, sizeof(buf) );
	em2027_cmd(f, SCANNER_CMD_SET_STOP_SUFFIX, buf, sizeof(buf) );
	em2027_cmd(f, SCANNER_CMD_ENABLE_STOP_SUFFIX, buf, sizeof(buf) );
	em2027_cmd(f, SCANNER_CMD_CODE_ID_ON, buf, sizeof(buf) );
	
	em2027_cmd(f, SCANNER_CMD_CONSTRAIN_MULTI_ON, buf, sizeof(buf) );
	em2027_cmd(f, SCANNER_CMD_CONSTRAIN_MULTI_SEMI, buf, sizeof(buf) );
	
	em2027_cmd(f, SCANNER_CMD_2D_DISABLE, buf, sizeof(buf) );

	em2027_cmd(f, SCANNER_CMD_ILLUMINATION_ON, buf, sizeof(buf) );

	em2027_cmd(f, SCANNER_CMD_AIM_WINK, buf, sizeof(buf) );

	// scanner sensitivity low (has to be programmed)
	em2027_cmd(f, "0312040", buf, sizeof(buf) );
	em2027_cmd(f, "0000020", buf, sizeof(buf) );
	em2027_cmd(f, "0000000", buf, sizeof(buf) );
	em2027_cmd(f, SCANNER_CMD_SAVE, buf, sizeof(buf) );
	em2027_cmd(f, SCANNER_CMD_SENSITIVITY_LOW, buf, sizeof(buf) );

	// this should be the last: it enables scanning!
	em2027_cmd(f, SCANNER_CMD_AUTO_SCAN, buf, sizeof(buf) );
	
	printf("Success configuring and enabled scanner\n");
}

 

int main(int argc, char *argv[])
{
	printf("Open scanner device\n");
	int f = open( dev_scanner, O_RDWR );

	em2027_ping( f );
	em2027_disable( f );
	eme2027_read_version_info( f );
	em2027_set_defaults( f );
	em2027_configure( f, 0 );
	
	printf("Reading scanner\n");
	int count = 1;
	while(1)
	{
		char c;
		if( read(f, &c, 1) == 1 )
		{
			if( c == '\xff' )
			{
				time_t now = time(0);
				printf(" #%d at %s", count++, ctime(&now));
			}
			else
			{
				printf("%c", c);
			}
		}
		else
			usleep(1000);
	}

	return 0;
}
