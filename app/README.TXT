
Introduction
============

documentation for the Nquire can be found in ../doc/app


The application is mainly writting in Lua, with some C modules for implementing
special functionality not available in Lua by default. 

The application can be run on a normal linux desktop machine and will use the X
server for display output.

If run on a machine without X-windows, the SDL graphics library used for the
application will fall back to framebuffer video output using the /dev/fb0
device.

Documentation
=============


All software version dependend documentation can be found in then version control database (https://svn.mbarc.nl/newland/nquire/svn/trunk).
The application documentation can be found under trunk/doc/app.
The documentation for the OS can be found in trunk/rootfs_document

Process and other documentation can be found in trac (https://server.mbarc.nl/newland/nquire/trac)


Build environment
=================

cd /opt
sudo mkdir toolchain-newland
sudo chmod og+r toolchain-newland
cd toolchain-newland
sudo tar xjvf <TRUNK>/toolchain/nebsp-toolchain-arm-linux.tar.bz2
cd scratchbox/compilers/nebsp-arm/
sudo mv * ../../..
cd ../../..
rm -rf scratchbox


For running the software on a pc the software should be compiled 
with 'make arch=pc'. This requires installing extra packages:

apt-get install libcurl3 libldap2-dev libidn11-dev libcurl4-openssl-dev libilmbase-dev libgraphviz-dev libexif-dev libdjvulibre-dev libbz2-dev libwmf-dev libtiffxx0c2 libtiff4-dev librsvg2-dev libjasper-dev libopenexr-dev libopenexr6 libmagick9-dev libslang2-dev libaa1-dev libdirectfb-extra libcucul-dev libcaca-dev libasound2-dev libsysfs-dev libdirectfb-dev libsdl1.2-dev libgif-dev libsdl-image1.2-dev liblua5.1-curl0 lua5.1 libcurl3-dbg liblua5.1-0-dev

not found: libartsc0-dev


Note that al lot of packages are just installed as dependency


Building
========

Dependencies:

- lua 5.1
- sdl
- freetype2
- libungif
- gifsicle   (test directory)

Compile the application's modules by running 'make'


Release
=======

A release can be made in two ways for two purposes:

Official release
----------------

Build and test the application. Check in all code. Then:

   make clobber                    # clean up thourough
   make                            # correct build-date and version in sys.so
   make install                    # copy files to app-binary
   cd ../app-binary
   svn commit -m "Release n.m"

Than Newland China has to build and check-in an official release in 
trunk/cit200-upgrade-tools. After that the release can be make by:

   cd trunk/cit200-upgrade-tools
   make clean
   make

The release image can be found in trunk/cit200-upgrade-tools/release

Unofficial test release
-----------------------

An unnofficial test-release (e.g. release candidate) can be build by using

   cd trunk/app
   make clean
   make RELEASE_TAG=build.xyz dist
   
Note that the RELEASE_TAG is optional and can only be used when no files are
modified according to svn.

The built releease image can be found in trunk/app/release

Tools
=====

Development tools can be found in trunk/app/tools
The following tools are available:

cit-test                try out predefined escape commands
put [ip]                ftp app.tar and install to ip
install                 target script for un-tarring app.tar
cit-discover.sh         discover script with tcp dump output
cit-discover            discovery tool (use 'make' first)
make_firmware           script used for "make dist"
generate-codepage       tool for generating code-pages (cit-codepage.lua)
sim300com.c             simple serial port communicator (GPRS target develop)
cit_sn                  fake serial number (required for trunk/app/test)

cit-db                  made obsolete by trunk/cit200-windows-tools
cit-discover-sg15       made obsolete by the real SG15 management app.

Testing
=======

Automated tests are implemented in trunk/app/tests

Those tests run on the local host system by typing:

   make test
   
Note that those tests are far from complete. Manual target testing is required!


Running 
=======

On the nquire, start the application by running 
 
$ cd /cit200 && lua main.lua

On startup, the application will attempt to configure the network according to
the settings found in the configuration database. The application will detect
and initialize the scanner, and warn if any error occurs while doing this.

To produce more verbose logging output, use the -l parameter

$ cd /cit200 && lua ./main.lua -l 5

Or configure the logging level in cit.conf.

For running the app without watchdog:

   touch /etc/nowatchdog

Then reboot. Now, the application with not start the watchdog.


Web interface
=============

The application can be reached using a web browser. The default port is port
80, but if this port can not be opened (for example when not running with root
permission), port 8000 will be used instead. 


Source files
============

arial.ttf       the normal (256 char) font file.
arialuni.ttf    the arial uni font file that can be uploaded when using micro-sd
schema/			This directory contains the schema's for the configuration database
img/ 			Contains various images for fonts and web interface
base64.c		Base64 encoding/decoding, used for basic auth in webserver
beeper.lua		Beeper driver. Not yet functional on CIT due to hardware issues
beepthread.c	Separate process for driving beeper
cit-codepages.lua codepage translation tables (see: tools/generate-codepage)
cit.lua			impleicit state machine and CIT protocol implementation
config.lua		Configuration database management
config_node.lua	Configuration database management
discovery.lua
discovery_sg15.lua
display.lua		Generic display code
dpydrv.c        Full-featured display driver using truetype fonts
evq.lua			Event queue management
format.lua		Helper functions for formatting strings
getopt.lua		Getopt function for command line arguments
gpio.lua        gpio handling
led.lua
log.lua			Logging to console and/or syslog
main.lua*		Main application
mifare.c        interface to mifare driver
misc.h
misc.lua
net.c			Low-level network code for socket handling
network.lua		Network configuration for ethernet, GPRS and wifi
scanner.lua		Scanner definitions (prefix translations)
scanner_1d.lua  handling internal em1300 scanner
scanner_2d.lua  handling internal em2027 scanner
scanner_rf.lua  handling mifare
scanner_hid     handling external scanner
strict.lua
sys.c			Some low-level helper functions and version info written in C
typecheck.lua	Typechecking for configuration database 
upgrade.lua
versioninfo.lua
watchdog.lua
webserver.lua	Webserver implementation
webui.lua		CGI implementation for configuration web interface


