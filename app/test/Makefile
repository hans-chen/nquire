#
# app/test/Makefile
# 
# makefile for testing (lua) modules from the nquire application
# run with memory check: 
#   valgrind --track-origins=yes --leak-check=full -v lua display_tester.lua
#
# Note: there is a memory leak in SDL_init of 38 bytes in 5 blocks.
#

# test and module definitions:
TESTS   += net_tester.lua base64_tester.lua misc_tester.lua config_tester.lua display_tester.lua sys_tester.lua

# dependencies per test:
net_tester.lua_DEP = net.so
base64_tester.lua_DEP = base64.so
misc_tester.lua_DEP = sys.so ../misc.lua
display_tester.lua_DEP = dpydrv.so sys.so img/anim.gif ../display.lua
config_tester.lua_DEP = sys.so base64.so ../config.lua

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

# auto vars:

TEST_RESULTS = $(foreach t,$(TESTS),results/$t.out)

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

test: $(TEST_RESULTS)
	meld verified results

clean:
	-rm -f $(MODULES) results/*
	cd img && make clean

clobber: clean
	-rm -rf results *~ img/anim.gif config_tester.conf
	cd img && make clobber

debug:
	@echo "TESTS=$(TESTS)"
	@echo "TEST_RESULTS=$(TEST_RESULTS)"

.PHONY: img
img:
	cd img && make

$(TESTS) $(MODULES): Makefile
display_tester.lua: img
$(TEST_RESULTS): TEST=$(notdir $(@:.out=))
$(TEST_RESULTS):
	# making $@ from $^
	mkdir -p results
	chmod +x $(TEST)
	$(TEST) | sed 's/^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9].*\[/\[/' | tee $@


%.so: ../%.c
	$(CC) -shared $(CFLAGS) $< -o $@ $(LDFLAGS) $(CFLAGS_$@) $(LDFLAGS_$@)
	chmod -x $@


.SECONDEXPANSION:

$(TEST_RESULTS): $$($$(notdir $$(patsubst %.out,%,$$@))_DEP)
$(TEST_RESULTS): $$(notdir $$(patsubst %.out,%,$$@))


