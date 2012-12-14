#
# Makefile
#
# makefile for the nquire-server-demo
#
# Author: M.R. van dootingh
# Date: febr 5 2010
#

# exe targets:
ALL_EXE = nquire-server.exe nquire-cmd.exe
ALL_TESTS = misc-tester database-tester

nquire-server.exe_SRC = ../nquire-common/misc.cpp database.cpp server.cpp
nquire-cmd.exe_SRC = ../nquire-common/misc.cpp nquire-cmd.cpp
misc-tester_SRC = ../nquire-common/misc.cpp ../nquire-common/misc-tester.cpp
database-tester_SRC = database.cpp database-tester.cpp ../nquire-common/misc.cpp

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

# public targets: 
.PHONY: all clean clobber compare

all: $(ALL_TARGETS)

test: $(ALL_TESTS:%=testresults/%.res) compare

clean:
	rm -f $(ALL_TARGETS) *.o testresults/*.res
	
distclean: clean
	rm -f *~
	rm -rf testresults
	rm -f nquire-server.log database-tester.log .dependencies.mk

install: nquire-server.exe nquire-cmd.exe
	if test -d ~/bin; then cp nquire-server.exe nquire-cmd.exe ~/bin; fi

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
	# $@
	$(CCC) -Wall -g $(CPPFLAGS) $(CFLAGS) $(OBJ) -o $@

$(ALL_TESTRESULTS): EXE=$(notdir $(basename $@))
$(ALL_TESTRESULTS):
	# $@: $^
	# executing $(EXE)
	mkdir -p testresults
	$(EXE) > $@ 2>&1

.dependencies.mk: Makefile
	$(CCC) -M $(CPPFLAGS) $(CFLAGS) $(ALL_SRC) > $@ 

include .dependencies.mk

.SECONDEXPANSION:

$(ALL_TESTRESULTS): $$(notdir $$(basename $$@))

# Note that this way only .cpp source is supported
$(ALL_TARGETS): $$(patsubst %.cpp,%.o,$$($$@_SRC))

