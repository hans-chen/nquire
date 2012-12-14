#
# app/tools/Makefile
# 
# makefile for compiling tools
#

# modules
MODULES += dpydrv.so sys.so net.so sim300com batchcode.gif

# extra compile flags per module:
LDFLAGS_dpydrv.so	+= -lrt -lungif -lSDL_image -lfreetype
CFLAGS_sys.so += -DVERSION=0 -DBUILD=0
LDFLAGS_sys.so	+= -lrt -lutil -lm -ldl 

# compile flags

PKGS	+= lua5.1 sdl freetype2
CFLAGS  += -g -Wall -Werror -O0
CFLAGS	+= -fPIC
LDFLAGS += -g -Wl,--export-dynamic

# auto vars:

# arch=pc
CFLAGS	+= `pkg-config --cflags $(PKGS) lua5.1`
LDFLAGS	+= `pkg-config --libs $(PKGS) lua5.1`

CC 	    = gcc
AR      = ar
LD 	    = ld
STRIP   = strip
MAKE	= $(MAKE)


.PHONY: all test clean clobber

all: $(MODULES) $(TESTS)

clean:
	-rm -f $(MODULES)

clobber: clean
	-rm -rf results *~ img/anim.gif

debug:

%.so: ../%.c
	$(CC) -shared $(CFLAGS) $< -o $@ $(LDFLAGS) $(CFLAGS_$@) $(LDFLAGS_$@)
	chmod -x $@

batchcode.gif:
	../../app/tools/gen-batchcode


sim300com: sim300com.c
	/opt/toolchain-newland/bin/arm-softfloat-linux-gnueabi-gcc -g -Wall -O3 -Werror  -fPIC -I../toolchain/usr/include -I../toolchain/usr/include/SDL -I../toolchain/usr/include/freetype2 sim300com.c -o sim300com
