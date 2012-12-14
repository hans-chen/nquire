#include   <stdio.h>
#include   <string.h>
#include   <unistd.h>
#include   <fcntl.h>
#include   <errno.h>
#include   <termios.h>
#include   <sys/time.h>
#include   <stdlib.h>

char rbuf[256],rbuf1[256];

int openport(char *Dev)
{
	int fd = open( Dev, O_RDWR|O_NOCTTY|O_NDELAY );
	if (-1 == fd)
	{   
		perror("Can't Open Serial Port");
		return -1;
	}
	else
		return fd;

}
  
int setport(int fd, int baud,int databits,int stopbits,int parity)
{
	int baudrate;
	struct   termios   newtio;
	switch(baud)
	{
		case 300:
			baudrate=B300;
			break;
		case 600:
			baudrate=B600;
			break;
		case 1200:
			baudrate=B1200;
			break;
		case 2400:
			baudrate=B2400;
			break;
		case 4800:
			baudrate=B4800;
			break;
		case 9600:
			baudrate=B9600;
			break;
		case 19200:
			baudrate=B19200;
			break;
		case 38400:
			baudrate=B38400;
			break;
		default :
			baudrate=B9600;
			break;
	}
	tcgetattr(fd,&newtio);   
	bzero(&newtio,sizeof(newtio));
	//setting   c_cflag
	newtio.c_cflag   &=~CSIZE;   
	switch (databits)
	{
		case 7:
			newtio.c_cflag |= CS7; 
			break;
		case 8:   
			newtio.c_cflag |= CS8; 
			break;
		default:  
			newtio.c_cflag |= CS8;
			break;   
	}

	switch (parity) //ÉèÖÃÐ£Ñé
	{
		case 'n':
		case 'N':  
			newtio.c_cflag &= ~PARENB;   /* Clear parity enable */
			newtio.c_iflag &= ~INPCK;     /* Enable parity checking */
			break;
		case 'o':
		case 'O':   
			newtio.c_cflag |= (PARODD | PARENB); 
			newtio.c_iflag |= INPCK;             /* Disnable parity checking */
			break;
		case 'e':
		case 'E':
			newtio.c_cflag |= PARENB;     /* Enable parity */  
			newtio.c_cflag &= ~PARODD;     
			newtio.c_iflag |= INPCK;       /* Disnable parity checking */
			break;
		case 'S':
		case 's': /*as no parity*/
			newtio.c_cflag &= ~PARENB;
			newtio.c_cflag &= ~CSTOPB;
			break;
		default:
			newtio.c_cflag &= ~PARENB;   /* Clear parity enable */
			newtio.c_iflag &= ~INPCK;     /* Enable parity checking */
			break;  
	}

	switch (stopbits)
	{
		case 1:  
			newtio.c_cflag &= ~CSTOPB; //1
			break;
		case 2:  
			newtio.c_cflag |= CSTOPB; //2
			break;
		default:
			newtio.c_cflag &= ~CSTOPB;
			break;
	}
	newtio.c_cc[VTIME] = 10;  
	newtio.c_cc[VMIN] = 0;
	newtio.c_cflag   |=   (CLOCAL|CREAD);
	newtio.c_oflag|=OPOST;
	newtio.c_iflag &=~(IXON|IXOFF|IXANY);
	             
	cfsetispeed(&newtio,baudrate);
	cfsetospeed(&newtio,baudrate);
	newtio.c_lflag     &= ~(ICANON | ECHO | ECHOE | ISIG);
	newtio.c_oflag     &= ~OPOST;
	tcflush(fd,   TCIOFLUSH);
	if (tcsetattr(fd,TCSANOW,&newtio) != 0)
	{
		perror("SetupSerial 3");
		return -1;
	}
	return 0;
}

int readport(int fd, char *buf,int len,int maxwaittime)
{
	int no=0;
	int rc;
	struct timeval tv;

	fd_set readfd;
	tv.tv_sec=maxwaittime/1000;    //SECOND
	tv.tv_usec=maxwaittime%1000*1000; //USECOND
	FD_ZERO(&readfd);
	FD_SET(fd,&readfd);
	memset(buf,0,len);
	rc=select(fd+1,&readfd,NULL,NULL,&tv);

	if(rc>0)
	{
		tv.tv_sec=4;  // SECOND
		tv.tv_usec=0; // USECOND
		
		do
		{
			rc=select(fd+1,&readfd,NULL,NULL,&tv);
			if(rc>0)
			{
				rc = read(fd,&buf[no],1);
				no += rc;
			}
		}
		while(rc>0 && strcmp(&buf[no-2],"OK")!=0);

		return no;     
	}

	return -1;
}



int writeport(int fd, char *buf,int len) 
{
	return write(fd,buf,len);
}

void clearport(int fd)     
{
	tcflush(fd,TCIOFLUSH);
}

int check_recv(char *buf,int sno)
{
switch(sno)
   {
   case 0:
   case 1:
   case 3:
  
       if(strcmp(&buf[2],"OK")==0)
        {
         printf("check_recv:%d\n",strcmp(&buf[2],"OK"));
         return 0;
        }
       else
         return -1;
         //if(strcmp(buf,"ERROR")==0
        break;
   case 2:
        if(strcmp(&buf[2],"SHUT OK")==0)
        {
         printf("%d\n",strcmp(&buf[2],"SHUT OK"));
         return 0;
        }
       else
        return -1;
       break;
   case 4:
        if(strcmp(&buf[2],"CONNECT OK")==0)
        {
         printf("%d\n",strcmp(&buf[2],"CONNECT OK"));
         return 0;
        }
       else
        return -1;
       break;
   case 5:
        if(strcmp(&buf[2],"> ")==0)
        {
         printf("%d\n",strcmp(&buf[2],"> "));
         return 0;
        }
       else
        return -1;
       break;
   case 6:
        if(strcmp(&buf[2],"SEND OK")==0)
        {
         printf("%d\n",strcmp(&buf[2],"SEND OK"));
         return 0;
        }
       else
        return -1;
      break;
   case 7:
        if(strcmp(&buf[2],"STATE: CONNECT OK")==0)
        {
         printf("%d\n",strcmp(&buf[2],"STATE: CONNECT OK"));
         return 0;
        }
       else
        return -1;
      break;
default :
return -1;
   }

}
int modem_init( int fd)
{
	int rc=-1;
	int i;

	for( i = 6; i>0; i-- )
	{
		writeport(fd,"AT\r",strlen("AT\r")+1);
		printf("send:AT\n");
		rc=readport(fd,rbuf,32,10000);

		printf("recv[%d]:'%s'\n",rc,rbuf);

		usleep(200000);
	}

	if(rc>0)                   //modem link send ate0 
	{
  
		writeport(fd,"ATE0\r",strlen("ATE0\r")+1);
		printf("send:ATE0\n");
		rc=readport(fd,rbuf,32,10000);
		printf("recv[%d]:%s\n",rc,rbuf);
	}

	return rc;
}


int main(int argc, char *argv[])
{
	int   fd,ret;
	char cmd[100];
	int cmd_eof=0;
	char *dev ="/dev/ttyS1";   

	fd = openport(dev);    
	if(fd>0)
	{
		ret=setport(fd,9600,8,1,'s'); 
		if(ret<0)
		{
		   printf("Can't Set Serial Port!\n");
		   exit(0);
		}
	}
	else
	{
		printf("Can't Open Serial Port!\n");
		exit(0);
	}

	clearport(fd);
	while (!cmd_eof)
	{
		printf("> ");
		scanf( "%s", cmd );
		strcat( cmd, "\r" );
		writeport(fd,cmd,strlen(cmd));
		char buf[256];
		readport(fd,buf,sizeof(buf),10000);
		printf("< '%s'\n",buf);
	}

	close(fd);

	return 0;
}
