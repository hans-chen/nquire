#
# Copyright © 2007 All Rights Reserved.
#

NAME    := cit-app
BUILD   := $(shell svnversion . | cut -d : -f 2)
VERSION	:= 1.3.2

###########################################################################
# Modules 
###########################################################################

PKGS			+= lua5.1 sdl freetype2

MODULES			+= sys.so
LDFLAGS_sys.so	+= -lrt -lutil -lm -ldl 

MODULES			+= net.so
MODULES			+= base64.so

MODULES 		+= dpydrv.so
LDFLAGS_dpydrv.so	+= -lrt -lungif -lSDL_image -lfreetype

MODULES			+= beepthread.so

MODULES			+= mifare.so
CFLAGS_mifare.so += -I../lib/rfid
LDFLAGS_mifare.so += ../lib/rfid/libnlrf.a

LUA_SRC             = $(shell ls -1 *lua)

INSTALL=../app-binary

###########################################################################
# Global 
###########################################################################

CFLAGS	+= -DVERSION=\"$(VERSION)\" -DBUILD=\"$(BUILD)\"
CFLAGS  += -g -Wall -Werror -O3 
CFLAGS 	+= $(ARCH_CFLAGS)
CFLAGS	+= -fPIC

LDFLAGS += -g -Wl,--export-dynamic
LDFLAGS += $(ARCH_LDFLAGS)

ifeq "$(arch)" "pc"
CFLAGS	+= `pkg-config --cflags $(PKGS) lua5.1`
LDFLAGS	+= `pkg-config --libs $(PKGS) lua5.1`
else
CROSS	:= /opt/toolchain-newland/bin/arm-softfloat-linux-gnueabi-
PATH_BUILD := ../toolchain/usr
CFLAGS	+= -I$(PATH_BUILD)/include
CFLAGS	+= -I$(PATH_BUILD)/include/SDL
CFLAGS	+= -I$(PATH_BUILD)/include/freetype2
LDFLAGS	+= -llua
LDFLAGS	+= -L$(PATH_BUILD)/lib
endif

###########################################################################
# Tools
###########################################################################

OBJS    = $(subst .c,.o, $(SRC))
CC 	= $(CROSS)gcc
AR  = $(CROSS)ar
LD 	= $(CROSS)ld
STRIP 	= $(CROSS)strip

###########################################################################
# Rules
###########################################################################

ifdef verbose
E	:=
P 	:= @true
MAKE	:= $(MAKE)
else
E	:= @
P	:= @echo
MAKE	:= $(MAKE) -s
endif

.PRECIOUS: $(MODULES)

all: $(MODULES) 

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	$(P) " [ SUB ] $@"
	$(E) $(MAKE) -C $@

%.o: %.c
	$(P) " [ CC  ] $@"
	$(E) $(CC) $(CFLAGS) -c $< -o $@ 

%.so: %.c
	$(P) " [ MOD ] $@"
	$(E) $(CC) -shared $(CFLAGS) $< -o $@ $(LDFLAGS) $(CFLAGS_$@) $(LDFLAGS_$@) 
	$(E) chmod -x $@


.PHONY: dist install

DIST=/tmp/$(NAME)-$(VERSION).$(BUILD).tar
$(DIST): Makefile install
	cd $(INSTALL) && tar cf $@ --exclude=.svn *

dist: MD5=$(shell md5sum $(DIST) | cut -d\  -f1 )
dist: $(DIST)
	cp $(DIST) $(NAME)-$(VERSION).$(BUILD)-$(MD5).image

clean:	
	$(P) " [CLEAN]"
	$(E) rm -rf $(OBJS) $(MODULES) core binary dist doc
	$(E) for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done

clobber: clean
	-rm -f *.image *~
	
install: $(MODULES)
	rm -f $(INSTALL)/*lua $(INSTALL)/*.so $(INSTALL)/*.ttf $(INSTALL)/schema/*
	cp *so $(INSTALL)
	cp arial.ttf $(INSTALL)
	cp schema/* $(INSTALL)/schema
	cp img/* $(INSTALL)/img
	for f in $(LUA_SRC); do luac -o $(INSTALL)/$$f $$f; done

-include ../Debrules.inc

