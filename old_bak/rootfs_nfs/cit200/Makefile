#
# Copyright © 2007 All Rights Reserved.
#

NAME    := cit
BUILD   := $(shell git-describe --always)
DIST	:= /tmp/$(NAME)-$(BUILD).tgz

###########################################################################
# Modules 
###########################################################################

PKG_all			+= lua5.1

MODULES			+= sys.so
LDFLAGS_sys.so		+= -lrt -lutil -lm -ldl 

MODULES			+= net.so
MODULES			+= base64.so

MODULES 		+= dpydrv.so
PKG_dpydrv.so		+= sdl freetype2
LDFLAGS_dpydrv.so	+= -lungif -lSDL_image -lrt

MODULES			+= beepthread.so

###########################################################################
# Global 
###########################################################################
CROSS   =  arm-linux-
CFLAGS	+= -DVERSION=\"$(VERSION)\" -DBUILD=\"$(BUILD)\"
CFLAGS  += -g -Wall -Werror -O3 
CFLAGS 	+= $(ARCH_CFLAGS)
CFLAGS	+= `pkg-config --cflags lua5.1`

LDFLAGS += -g -Wl,--export-dynamic
LDFLAGS += $(ARCH_LDFLAGS)
LDFLAGS	+= `pkg-config --libs lua5.1`

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
	$(E) $(CC) -shared $(CFLAGS) $< -o $@ $(LDFLAGS) $(CFLAGS_$@) $(LDFLAGS_$@) `pkg-config --cflags --libs $(PKG_all) $(PKG_$@)`
	$(E) chmod -x $@


.PHONY: dist install

dist:
	git-archive --prefix=$(NAME)-$(BUILD)/ --format=tar HEAD | gzip > $(DIST)

clean:	
	$(P) " [CLEAN]"
	$(E) rm -rf $(OBJS) $(MODULES) core binary dist doc
	$(E) for d in $(SUBDIRS); do $(MAKE) -C $$d clean; done

-include ../Debrules.inc

