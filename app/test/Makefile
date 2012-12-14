#
# app/test/Makefile
# 
# makefile for building and executing tests
#
# targets:
#	all			build tests
#	prepare		preparations for executing tests
#	discover	discover the nquire under test
#	clean
#	clobber
#	test		execute all tests that don't require specific HW (base_module + tests_base)
#	test_module	execute all tests that don't require HW
#	test_base	execute all tests that do not require specific HW options
#	test_mifare	execute all mifare testcases
#	show		show diff of test-results using meld
#
# some module tests are run with valgrind!


all:

# test and module definitions

MODULE_TESTS   += \
	module/net_tester.lua\
	module/base64_tester.lua\
	module/misc_tester.lua\
	module/config_tester.lua\
	module/display_tester.lua\
	module/sys_tester.lua\
	module/scanner_tester.lua\

TARGET_BASE_TESTS = \
	target/one-time-timeout-tester\

# and define tests for different HW options:
TARGET_MIFARE_TESTS = \
	target/mifare-write-tester\
	target/mifare-read-tester\

TARGET_TESTS = $(TARGET_BASE_TESTS) $(TARGET_MIFARE_TESTS)

# auto vars per HW option:

MODULE_TEST_RESULTS = $(foreach t,$(MODULE_TESTS),results/$(notdir $t).out)

TARGET_BASE_TEST_RESULTS = $(foreach t,$(TARGET_BASE_TESTS),results/$(notdir $t).out)
TARGET_MIFARE_TEST_RESULTS = $(foreach t,$(TARGET_MIFARE_TESTS),results/$(notdir $t).out)

TARGET_TEST_RESULTS = $(TARGET_BASE_TEST_RESULTS) $(TARGET_MIFARE_TEST_RESULTS)

# auto vars:

TEST_RESULTS = $(MODULE_TEST_RESULTS) $(TARGET_TEST_RESULTS)

# dependencies per test:
module_net_tester.lua_DEP = net.so
module_base64_tester.lua_DEP = base64.so
module_misc_tester.lua_DEP = sys.so ../misc.lua
module_display_tester.lua_DEP = dpydrv.so sys.so img/anim.gif ../display.lua minimal.supp
module_config_tester.lua_DEP = sys.so base64.so ../config.lua

# modules
MODULES += dpydrv.so sys.so base64.so net.so

# extra compile flags per module:
LDFLAGS_dpydrv.so	+= -lrt -lungif -lSDL_image -lfreetype
CFLAGS_sys.so += -DVERSION=0 -DBUILD=0
LDFLAGS_sys.so	+= -lrt -lutil -lm -ldl 

# compile flags

PKGS	+= lua5.1 sdl freetype2
CFLAGS  += -g -Wall -Werror -O0
CFLAGS	+= -fPIC
LDFLAGS += -g -Wl,--export-dynamic

# arch=pc
CFLAGS	+= `pkg-config --cflags $(PKGS) lua5.1`
LDFLAGS	+= `pkg-config --libs $(PKGS) lua5.1`

CC 	    = gcc
AR      = ar
LD 	    = ld
STRIP   = strip
MAKE	= $(MAKE)


.PHONY: all test clean clobber
#	test_base	execute all base

all: prepare

prepare: links $(MODULES)
	make -C img all
	make -C testserver all install

discover:
	nquire-discover.exe -1 > .cit.ip

test_module: $(MODULE_TEST_RESULTS)
test_base: $(TARGET_BASE_TEST_RESULTS)
test_mifare: $(TARGET_MIFARE_TEST_RESULTS)
test: test_module test_base

test%:
	if ! diff --exclude=.svn verified results; then echo "There were errors"; meld verified results; fi

show:
	meld verified results

# cleanup testresults etc, but don't remove prepare things
clean:
	-rm -f $(MODULES) results/*

clobber: clean
	-rm -rf results *~ img/anim.gif config_tester.conf
	-rm -f schema config_tester.conf1 cit.conf minimal.supp minimalraw.log
	make -C img clobber
	make -C testserver clobber

debug:
	@echo "TESTS=$(TESTS)"
	@echo "TEST_RESULTS=$(TEST_RESULTS)"

links:
	-rm -f schema; ln -fs ../schema .

.PHONY: img
# always execute tests when requested:
.PHONY:

img/anim.gif:
	make -C img

# generate a minimal suppression file for handling one-time only errors
minimalraw.log: Makefile dpydrv.so sys.so
	valgrind --leak-check=full --show-reachable=yes --error-limit=no --log-file=minimalraw.log --gen-suppressions=all -v lua module/display_tester.lua --min
minimal.supp: minimalraw.log
	cat ./minimalraw.log | ./parse_valgrind_suppressions.sh > minimal.supp

# special handling of display_tester for testing memoryleaks with valgrind
results/display_tester.lua.out:
	mkdir -p results
	chmod +x $(TEST)
	valgrind --leak-check=full --show-reachable=yes --error-limit=no --suppressions=minimal.supp -v lua module/display_tester.lua 2>&1 | sed 's/[-=][-=]....[-=][-=]//' | grep -v 'total heap usage' > $@

$(MODULE_TEST_RESULTS): TEST=module/$(basename $(notdir $@))
$(TARGET_TEST_RESULTS): TEST=target/$(basename $(notdir $@))
$(TESTS_RESULTS) $(MODULES): Makefile
results/%.out: 
	# making $@ from $^
	mkdir -p results
	chmod +x $(TEST)
	$(TEST) | awk '/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9]/ { printf("%s %s\n", $$2, substr($$0,46)); next } { print; }' > $@ 2>&1


%.so: ../%.c
	$(CC) -shared $(CFLAGS) $< -o $@ $(LDFLAGS) $(CFLAGS_$@) $(LDFLAGS_$@)
	chmod -x $@


.SECONDEXPANSION:

$(MODULE_TEST_RESULTS): $$(module_$$(basename $$(notdir $$@))_DEP)
$(MODULE_TEST_RESULTS): module/$$(basename $$(notdir $$@))

$(TARGET_TEST_RESULTS): $$(target_$$(basename $$(notdir $$@))_DEP)
$(TARGET_TEST_RESULTS): target/$$(basename $$(notdir $$@))

