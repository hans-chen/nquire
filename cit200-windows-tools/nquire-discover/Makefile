#
# Makefile
#
# makefile for the nquire-discover demo program
#
# Author: M.R. van dootingh
# Date: febr june 12 2011
#

# compile flags:
CFLAGS = -g -Wall -Werror
CPPFLAGS = -I../nquire-common

# compiler, etc
CC=gcc
CCC=g++

SHELL=/bin/bash

# public targets: 
.PHONY: all clean clobber compare

all: nquire-discover.exe

clean:
	rm -f nquire-discover.exe *.o ../nquire-common/*.o
	
# install in private bin directory for testing purposes
install: nquire-discover.exe
	if test -d ~/bin; then cp nquire-discover.exe ~/bin; fi

nquire-discover.exe: nquire-discover.o ../nquire-common/misc.o
	# $@
	$(CCC) -Wall -g $(CPPFLAGS) $(CFLAGS) nquire-discover.o ../nquire-common/misc.o -o $@

nquire-discover.o: ../nquire-common/misc.h
../nquire-common/misc.o: ../nquire-common/misc.h
