
#include <stdio.h>
#include <time.h>
#include <sys/select.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <ctype.h>

#include "serial.h"

int hex_mode = 0;
int binary_mode = 1;
int translate_newline = 0;

void usage(char *fname);
void line(void);
int handle_serial(int fd_in, int fd_out);
int handle_terminal(int fd_in, int fd_out);
int write_all(int fd, const void *buf, size_t count);

int main(int argc, char **argv)
{
	struct timeval tv;
	fd_set fds;
	int fd_serial;
	int fd_terminal;
	struct termios save;
	int r;
	int o;
	int rtscts = 0;
	int baudrate = 9600;
	char ttydev[32] = "/dev/ttyS0";
//	char buf[256];
	
	while( (o = getopt(argc, argv, "bhnrx")) != EOF) {
		switch(o) {
			case 'b':
				binary_mode = 1;
				break;
			case 'h':
				usage(argv[0]);
				exit(0);
			case 'n':
				translate_newline = 1;
				break;
			case 'r':
				rtscts=1;
				break;
			case 'x':
				hex_mode = 1;
				break;
		}
	}

	if(argc - optind < 2) {
		usage(argv[0]);
		exit(1);
	}
	
	strncpy(ttydev, argv[optind+0], sizeof(ttydev));
	baudrate = atoi(argv[optind+1]);

	printf("Connect to %s at %d bps\n", ttydev, baudrate);
	line();
	
	fd_serial   = serial_open(ttydev, baudrate, rtscts);
	fd_terminal = 0;
	
	set_noncanonical(fd_serial, NULL);
	set_noncanonical(fd_terminal, &save);
	
	while(1) {
	
		FD_ZERO(&fds);
		FD_SET(fd_serial, &fds);
		FD_SET(fd_terminal, &fds);
		
		tv.tv_sec = 1;
		tv.tv_usec = 0;
		
		r = select(8, &fds, NULL, NULL, &tv);
		
		if(r > 0) {
			
			if(FD_ISSET(fd_serial, &fds)) {
			
				r = handle_serial(fd_serial, fd_terminal);
				if(r == -1) goto cleanup;
			}
			
			if(FD_ISSET(fd_terminal, &fds)) {
			
				r = handle_terminal(fd_terminal, fd_serial);
				if(r == -1) goto cleanup;
			}
			
		} else if(r<0) {
			goto cleanup;
		}
		
	}

cleanup:	
	r = tcsetattr (fd_terminal, TCSANOW, &save);
	line();
	return(0);
}



int handle_serial(int fd_in, int fd_out)
{
	char c[128];
	int len;
	char buf[32];
	int r;
	int i;
	char *p;

	len = read(fd_in, c, sizeof(c));
	if(len <= 0) return -1;
	
	p = c;
	
	for(i=0; i<len; i++) {

		if(binary_mode) {
			write_all(fd_out, p, 1);
		} else {

			if (!hex_mode && (isprint(*p) || isspace(*p) || (*p==127) || (*p==8)) ) {
				write_all(fd_out, p, 1);
			} else {
				r = snprintf(buf, sizeof(buf), "[%02x]", *(unsigned char *)p);
				write_all(fd_out, buf, r);
			}
		}
		p++;
	}

	return 0;
}


int handle_terminal(int fd_in, int fd_out)
{
	char c;
	int len;
	static int in_hex;
	static int escape = 0;
	static int hexval = 0;
	int r;

	len = read(fd_in, &c, 1);
	
	if(escape) {
	
		if(c == '~') {
			write_all(fd_out, &c, 1);
		}
		
		else if(c == '.') {
			putchar('\n');
			return -1;
		}

		else if(c == 'b') {
			r = tcsendbreak(fd_out, 0);
			if(r == -1) {
				printf("<brk err>");
			} else {
				printf("<brk>");
			}
			fflush(stdout);
		}
		
		else if(c == 'd') {
			serial_set_dtr(fd_out, 0);
			printf("<DTR hop>\n");
			sleep(1);
			serial_set_dtr(fd_out, 1);
		}
		
		else if(c == 'x') {
			in_hex = 1;
		}
		
		else  {
			printf("\n");
			printf("  ~~    send tilde\n");
			printf("  ~.    exit\n");
			printf("  ~b    send break\n");
			printf("  ~d    dtr hop\n");
			printf("  ~xNN  enter HEX character\n");
		}
		
		escape = 0;
		
	} 
	
	else if(in_hex) {
	
		c = tolower(c);
		c = c - '0';
		if(c > 9) c -= 39;
		
		hexval = (hexval << 4) + c;

		if(++in_hex > 2) {
			write_all(fd_out, &hexval, 1);
			in_hex = 0;
		}
		
	}
		
	
	else {
		if(c == '~') {
			escape = 1;
		} else {
			if(translate_newline) {
				if(c == '\n') c = '\r';
			}
			write_all(fd_out, &c, 1);
		}
	}
	
	return 0;
}	




void usage(char *fname)
{
	printf("usage: %s [-r] <port> <baudrate\n", fname);
	printf("\n");
	printf("  -b	binary mode, do interpret all control codes\n");
	printf("  -n    translate newline to cr\n");
	printf("  -r	use RTS/CTS hardware handshaking\n");
	printf("  -x	HEX mode\n");
}

void line(void)
{
	int i;
	for(i=0; i<80; i++) putchar('-');
	putchar('\n');
}


int write_all(int fd, const void *buf, size_t count)
{
	fd_set fds;
	size_t written = 0;
	int r;

	while(written < count) {

		FD_ZERO(&fds);
		FD_SET(fd, &fds);
		r = select(fd+1, NULL, &fds, NULL, NULL);
		if(r < 0) return r;

		r = write(fd, buf+written, count-written);
		if(r < 0) return r;

		written += r;
	}

	return written;
}



/*
 * End
 */
