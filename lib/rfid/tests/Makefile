CC		:= /scratchbox/compilers/nebsp-arm/bin/arm-linux-gcc

default:
	@$(CC) main.c -o rfiddemo -Wall -I../include -L.. -lnlrf

static:
	@$(CC) main.c -o rfiddemo -Wall -I../include -L.. -lnlrf -static

clean:
	@rm -f rfiddemo
