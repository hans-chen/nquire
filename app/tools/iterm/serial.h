/* serial.c */
int serial_open(char *dev, int baudrate, int rtscts);
int set_noncanonical(int fd, struct termios *save);
int serial_set_dtr(int fd, int state);
