#
# Copyright © 2007 All Rights Reserved.
#
# usage:
# 
# make clean|clobber|all|install|app.tar|{[RELEASE_TAG=- | RELEASE_TAG=mytag] dist}
#
# Without RELEASE_TAG the tag for a distribution will be "trunk"<buildnr>
# No tag will be used when RELEASE_TAG=-
# Note that you should only build an official release when nothing is checked out
#
# eg:
# make RELEASE_TAG=beta1 dist
#

NAME    := cit-app
BUILD   := $(shell svnversion -c . | cut -d : -f 2)
# only use a major and a minor verion number
# patch level numbering is not SG15 compatible!
VERSION	:= 1.6
LABEL := $(VERSION).$(BUILD)

all:

# Auto vars:

SHELL = bash
ifdef RELEASE_TAG
# this is not allowed from a modified build:
RELEASE_REJECT=$(shell if [[ "$(BUILD)" =~ .*M$$ ]]; then echo "YES";fi)
ifeq "$(RELEASE_REJECT)" "YES"
$(error You cann't make an official release from a modified build")
else
ifeq "$(RELEASE_TAG)" "-"
	R_TAG = $(VERSION)
else
	R_TAG = $(VERSION).$(RELEASE_TAG)
endif
endif
else
LOC=$(shell if [[ "~/workspace/mbarc/trunk/src/validator2" =~ .*\/trunk\/.* ]]; then echo trunk; else echo tag_or_branch; fi)
R_TAG = $(VERSION).$(LOC)$(BUILD)
endif

###########################################################################
# Modules 
###########################################################################

PKGS			+= lua5.1 sdl freetype2

SUBDIRS			+= test tools

MODULES			+= sys.so
LDFLAGS_sys.so	+= -lrt -lutil -lm -ldl 

MODULES			+= net.so
MODULES			+= base64.so

MODULES 		+= dpydrv.so
dpydrv.so: LDFLAGS += -lrt -lungif -lSDL_image -lfreetype

MODULES			+= beepthread.so

MODULES			+= mifare.so
mifare.so : CFLAGS += -I../lib/rfid
#mifare.so : LDFLAGS += -Wl,-Bstatic ../lib/rfid/libnlrf.a -Wl,-Bdynamic
mifare.so : LDFLAGS += -L../lib/rfid/ -lnlrf

EXE += gethostbyname
gethostbyname: gethostbyname.c

LUA_SRC             = $(shell ls -1 *lua)

INSTALL=../app-binary

###########################################################################
# Global 
###########################################################################

CFLAGS	+= -DVERSION=\"$(VERSION)\" -DBUILD=\"$(BUILD)\"
CFLAGS  += -g -Wall -Werror -O3 
CFLAGS 	+= $(ARCH_CFLAGS)
CFLAGS	+= -fPIC

# 'install' lua by copy, not compiled with luac
ifdef DEBUG
CFLAGS 	+= -DDEBUG
endif

# turn on tracing in c-files
ifdef TRACEON
CFLAGS 	+= -DTRACEON
endif

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
#/opt/toolchain-newland/bin/arm-softfloat-linux-gnueabi-strip

###########################################################################
# Rules
###########################################################################

.PRECIOUS: $(MODULES)

all: $(SUBDIRS) $(MODULES) links $(EXE)

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	@echo "[SUBDIR $@]"
	$(MAKE) -C $@

%.o: %.c
	@echo "[$@]"
	$(CC) $(CFLAGS) -c $< -o $@ 

%.so: %.c
	@echo "[$@]"
	$(CC) -shared $(CFLAGS) $< -o $@ $(LDFLAGS) $(CFLAGS_$@) $(LDFLAGS_$@) 
	$(STRIP) $@
	chmod -x $@

gethostbyname: gethostbyname.o
	$(CC) $(CFLAGS) $< -o $@ -L../toolchain/usr/lib  
	$(STRIP) $@
	chmod 751 $@
	
.PHONY: dist install links clean clobber

# Note that this builds a release from app-binary!
# When current changes should be included you have to "make install" first
dist: app.tar
	@echo "[$@]"
	tools/make_firmware $(R_TAG)

links: 
	@echo "[$@]"
	ln -sf tools/put .
	ln -sf tools/install .
	
clean:	
	@echo "[$@]"
	-rm -rf binary dist doc
	-rm -f $(OBJS) $(MODULES) core $(EXE) gethostbyname.o
	for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done

clobber: clean
	@echo "[$@]"
	-rm -f *.image *~ cit-db cit-discover cit-discover-sg15 cit-discover.sh 
	-rm -f install put cit-test app.tar `find . -name '.cit.ip'`
	for d in $(SUBDIRS); do $(MAKE) -C $$d clobber; done

clobber_install:
	@echo "[$@]"
	-rm -f $(INSTALL)/*lua $(INSTALL)/*.so $(INSTALL)/*.ttf $(INSTALL)/schema/* 
	-rm -f $(INSTALL)/img/*.gif $(INSTALL)/img/*.jpg $(INSTALL)/img/*.png $(INSTALL)/img/keypad/*

ifdef DEBUG
$(INSTALL)/%.lua:%.lua
	cp -f $< $@
else
$(INSTALL)/%.lua:%.lua
	luac -o $@ $<
endif

$(INSTALL)/%.so:%.so
	cp -f $< $@

install: clobber_install \
		$(EXE) $(LUA_SRC:%=$(INSTALL)/%) $(MODULES:%=$(INSTALL)/%)
	@echo "[$@]"
	cp -a cit arial.ttf gethostbyname $(INSTALL)/
	cp -a http/* $(INSTALL)/http/
	cp -a schema/*.schema $(INSTALL)/schema/
	cp -a img/ftp/* $(INSTALL)/img/ftp/

app.tar: Makefile install
	@echo "[$@]"
	cd $(INSTALL) && tar cvf ../app/$@ --exclude=.svn *

-include ../Debrules.inc

