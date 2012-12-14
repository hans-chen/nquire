#
# Makefile
#
# makefile for the example tooling for the nquire
#
# Author: M.R. van dootingh
# Date: febr 5 2010
#

# exe targets:
ALL_EXE = nquire-server.exe nquire-cmd.exe nquire-discover.exe
ALL_TESTS = misc-tester database-tester

nquire-discover.exe_SRC = misc.cpp nquire-discover.cpp
nquire-server.exe_SRC = misc.cpp database.cpp server.cpp
nquire-cmd.exe_SRC = misc.cpp nquire-cmd.cpp
misc-tester_SRC = misc.cpp misc-tester.cpp
database-tester_SRC = database.cpp database-tester.cpp misc.cpp

# compile flags:
CFLAGS = -g -Wall -Werror -O0
CXXFLAGS =  -g -Wall -Werror -O0
CPPFLAGS = -I../nquire-common

# auto vars:
ALL_TESTRESULTS = $(ALL_TESTS:%=testresults/%.res)
ALL_TARGETS = $(ALL_EXE) $(ALL_TESTS)
ALL_SRC = $(foreach t,$(ALL_TARGETS),$($t_SRC))

# compiler, etc
CC=gcc
CCC=g++

ifdef windir
PLATFORM=WIN32
endif

ifeq ($(PLATFORM),WIN32)
LDFLAGS = -lws2_32 -liphlpapi
RM=del 
else
RM=rm -f
endif

# public targets: 
.PHONY: all clean clobber compare

all: $(ALL_TARGETS)

test: $(ALL_TESTS:%=testresults/%.res) compare

clean:
	-$(RM) $(ALL_TARGETS) *.o $(ALL_TESTS:=.exe)
	-$(RM) testresults/*.res
ifeq ($(PLATFORM),WIN32)
	-del testresults\*.res
else
	rm -f testresults/*.res
endif

install: nquire-server.exe nquire-cmd.exe
	if test -d ~/bin; then cp nquire-server.exe nquire-cmd.exe nquire-discover.exe ~/bin; fi

debug:
	@echo "ALL_EXE=$(ALL_EXE)"
	@echo "ALL_TESTS=$(ALL_TESTS)"
	@echo "ALL_TESTRESULTS=$(ALL_TESTRESULTS)"
	@echo "ALL_TARGETS=$(ALL_TARGETS)"
	@echo "ALL_SRC=$(ALL_SRC)"
	
compare: $(ALL_TESTRESULTS)
	if ! diff verified/ testresults/; then meld verified/ testresults/; fi

# 'private' targets

$(ALL_TARGETS): SRC=$($@_SRC)
$(ALL_TARGETS): OBJ=$(SRC:.cpp=.o)
$(ALL_TARGETS): 
	$(CCC) -Wall -g $(CPPFLAGS) $(CFLAGS) $(OBJ) $(LDFLAGS) -o $@

$(ALL_TESTRESULTS): EXE=$(notdir $(basename $@))
$(ALL_TESTRESULTS):
	mkdir -p testresults
	$(EXE) > $@ 2>&1

misc.o: misc.cpp misc.h
database.o: database.cpp database.h misc.h
server.o: server.cpp misc.h database.h
nquire-cmd.o: nquire-cmd.cpp misc.h 
misc-tester.o: misc-tester.cpp misc.h tester.h
database-tester.o: database-tester.cpp database.h misc.h tester.h 
nquire-discover.o: misc.h

.SECONDEXPANSION:

$(ALL_TESTRESULTS): $$(notdir $$(basename $$@))

# Note that this way only .cpp source is supported
$(ALL_TARGETS): $$(patsubst %.cpp,%.o,$$($$@_SRC))

