#
# Makefile
#
# makefile for the nquire-server-demo
#
# Author: M.R. van dootingh
# Date: febr 5 2010
#

# exe targets:
ALL_EXE = nquire-discover.exe
ALL_TESTS = 

nquire-discover.exe_SRC = common/misc.cpp nquire-discover.cpp

# compile flags:
CFLAGS = -g -Wall -Werror
CPPFLAGS = -Icommon

# auto vars:
ALL_TESTRESULTS = $(ALL_TESTS:%=testresults/%.res)
ALL_TARGETS = $(ALL_EXE) $(ALL_TESTS)
ALL_SRC = $(foreach t,$(ALL_TARGETS),$($t_SRC))

# compiler, etc
CC=gcc
CCC=g++

SHELL=/bin/bash

# public targets: 
.PHONY: all clean clobber compare

all: $(ALL_TARGETS)

test: $(ALL_TESTS:%=testresults/%.res) compare

clean:
	rm -f $(ALL_TARGETS) *.o testresults/*.res
	
clobber: clean
	rm -f *~
	rm -rf testresults .dependencies.mk

# install in private bin directory for testing purposes
install: nquire-discover.exe
	if test -d ~/bin; then cp nquire-discover.exe ~/bin; fi

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


