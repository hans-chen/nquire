#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <termios.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <errno.h>

#include "serial.h"

int serial_open(char *dev, int baudrate, int rtscts)
{
	int fd = 0;
	int br;
	int r;
	struct termios tios;

	fd = open (dev, O_RDWR | O_NOCTTY | O_NDELAY);
	
	if (fd < 0) {
		perror (dev);
		exit (1);
	}

	switch(baudrate) {
		case    50:	br =  B50;    break;
		case   300:	br =  B300;   break;
		case  1200:	br =  B1200;  break;
		case  2400: 	br =  B2400;  break;
		case  4800:	br =  B4800;  break;
		case  9600:	br =  B9600;  break;
		case 19200:	br =  B19200; break;
		case 38400:	br =  B38400; break;
		case 57600:	br =  B57600; break;
		default:	br = B115200; break;
	}


//	tios.c_cflag = br | PARENB | CS7 | CLOCAL | CREAD;  
	tios.c_cflag = br | CS8 | CLOCAL | CREAD;  
	if(rtscts) tios.c_cflag |= CRTSCTS; 
	tios.c_iflag = IGNPAR;
	tios.c_oflag = OPOST;

	tcflush (fd, TCIFLUSH);
	r = tcsetattr (fd, TCSANOW, &tios);
	if(r != 0) printf("tcsetattr : %s\n", strerror(errno));

	return(fd);
}


int set_noncanonical(int fd, struct termios *save)
{
	int r;
	struct termios tios;
	
//	fcntl(fd, F_SETFL, 0);

	if(save) tcgetattr(fd, save);
	tcgetattr(fd, &tios);

	tios.c_lflag     = 0;
	tios.c_cc[VTIME] = 0;
	tios.c_cc[VMIN]  = 1;

	tcflush (fd, TCIFLUSH);
	r = tcsetattr (fd, TCSANOW, &tios);
	if(r != 0) printf("tcsetattr : %s\n", strerror(errno));

	return(0);
}


int serial_set_dtr(int fd, int state)
{
	int status;
	
	ioctl(fd, TIOCMGET, &status);
	if(state == 1) {
		status |= TIOCM_DTR;
	} else {
		status &= ~TIOCM_DTR;
	}
	ioctl(fd, TIOCMSET, &status);
	return(0);
}

// end
