#
# Copyright © 2007 All Rights Reserved.
#

NAME    := cit
VERSION	:= 1.0
BUILD   := $(shell svnversion . | cut -d : -f 2)
DIST	:= /tmp/$(NAME)-$(BUILD).tgz

###########################################################################
# Modules 
###########################################################################

PKGS			+= lua5.1 sdl freetype2

MODULES			+= sys.so
LDFLAGS_sys.so		+= -lrt -lutil -lm -ldl 

MODULES			+= net.so
MODULES			+= base64.so

MODULES 		+= dpydrv.so
LDFLAGS_dpydrv.so	+= -lrt -lungif -lSDL_image -lfreetype

MODULES			+= beepthread.so

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
LD 	= $(CROSS)gcc
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

dist:
	git-archive --prefix=$(NAME)-$(BUILD)/ --format=tar HEAD | gzip > $(DIST)

clean:	
	$(P) " [CLEAN]"
	$(E) rm -rf $(OBJS) $(MODULES) core binary dist doc
	$(E) for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done

install: $(MODULES)
	rm -f ../app-binary/*lua ../app-binary/*.so ../app-binary/*.ttf ../app-binary/schema/*
	cp *so ../app-binary
	cp arial.ttf ../app-binary
	cp schema/* ../app-binary/schema
	cp img/* ../app-binary/img
	for f in *lua; do luac -o ../app-binary/$$f $$f; done

-include ../Debrules.inc

