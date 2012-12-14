#
# app/test/testserver/makefile
#
# Makefile for building the testserver
#

ALL=testserver

testserver_SRC=testserver.cpp misc.cpp


CFLAGS += -g -Wall -Werror -O0 -lrt

# compiler, etc
CC=gcc
CCC=g++

# == auto vars ===



# == targets ===

all: $(ALL)

clean:
	rm -f $(ALL) *.o

clobber: clean
	rm -f *~ *.o
	
install: all
	-killall testserver
	if test -d ${HOME}/bin; then cp testserver ${HOME}/bin; fi

$(ALL): SRC=$($@_SRC)
$(ALL): OBJ=$(SRC:.cpp=.o)
$(ALL): 
	$(CCC) -Wall -g $(CPPFLAGS) $(CFLAGS) $(OBJ) -o $@

.SECONDEXPANSION:

$(ALL): $$(patsubst %.cpp,%.o,$$($$@_SRC))

