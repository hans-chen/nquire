/*
scangpi.c

This is a small program for scanning realtime events on the gpio
*/

#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <sys/select.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <termios.h>
#include <unistd.h>
#include <sys/socket.h>
#include <syslog.h>
#include <signal.h>
#include <linux/input.h>
#include <dirent.h>
#include <pty.h>
#include <malloc.h>

#define SETGPIOMODE     0x5510  //set gpio mode input = 0 output = 1 
#define GETGPIOMODE     0x5511  //get gpio mode
#define SETGPIOVALUE    0x5512  //set gpio value high = 1 low = 0 
#define GETGPIOVALUE    0x5513  //get gpio value 

#define GPIO1 1
#define GPIO3 3
#define GPIO5 5
#define GPIO7 7

#define GPIO_OUT 1
#define GPIO_IN  0
#define GPIO_HIGH 1
#define GPIO_LOW  0

typedef struct
{
	int pin_offset;                         
	int pin_mode;
	int pin_value;
} gpio_param;

static gpio_param in[2];
static uint16_t count_changed[2];
static int fd_gpi;
static FILE *fd_res;
static int debug;

void scan_and_write()
{
	int i;
	gpio_param in_prev[2];
	memcpy( in_prev, in, sizeof(in) );
	for(i=0; i<2; i++)
	{
		if(ioctl(fd_gpi, GETGPIOVALUE, &in[i])<0)
		{
			syslog(4,"Error reading GPI %d: %s\n", i, strerror(errno));
		}
	}

	if( memcmp( in, in_prev, sizeof(in) ) != 0 )
	{
		// write to file, each time at the beginning
		rewind(fd_res);
		for(i=0; i<2; i++)
		{
			if(in[i].pin_value != in_prev[i].pin_value)
				++count_changed[i];
			fprintf(fd_res,"GPI %d %d %d\n", in[i].pin_offset, in[i].pin_value, count_changed[i]);
			if(debug)
				syslog(LOG_DEBUG,"GPI %d %d %d\n", in[i].pin_offset, in[i].pin_value, count_changed[i]);
		}
		fflush(fd_res);
	}
}

int main(int argc, char *argv[])
{
	if(argc>1 && strcmp(argv[1],"-D")==0)
		debug=1;

	in[0] = (gpio_param){ 5, GPIO_IN,-1 };
	in[1] = (gpio_param){ 7, GPIO_IN,-1 };

	fd_gpi = open("/dev/gpio", O_RDWR);

	int i;
	for(i=0; i<2; i++)
	{
		if(ioctl(fd_gpi, GETGPIOMODE, &in[i])<0)
		{
			syslog(4, "Error initializing GPI %d: %s", i, strerror(errno));
		}
	}

	fd_res = fopen("/tmp/gpi", "w");
	// write initial values to file
	scan_and_write( );
	
	if( argc>1 && strcmp(argv[1],"-d")==0) 
	{
		// deamonize:
		if(fork() != 0)
		{
			syslog(5, "scangpi deamonize");
			exit(0);
		}
	}

	for(;;)
	{
		scan_and_write( );

		// every ~ .001 second...
		const struct timespec req = (struct timespec){0,1000000};
		struct timespec rem;
		nanosleep(&req, &rem);
	}

	return 0;
}

