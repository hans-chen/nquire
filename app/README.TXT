
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

Application description
=======================

The CIT application acts as a thin client network device. It is controlled over
the network by the 'SG15' protocol, which allowes a remote host to control the
display and to receive scanned barcodes. The main purpose of the CIT
application is to be used as a price-checker for retail and supermarkets.

The application has the following functionalities:

- CIT protocol implementation for controlling the display and for sending
  scanned barcodes. Please refer to the SG15 protocol documentation for the 
  exact protocol implementation

- A built-in webserver is used to provide a method of configuration for the
  end-user. The web server starts at the usual HTTP port 80

- Device discovery: The device implements a simple discovery mechanism using
  multicast UDP.

Building
========

Dependencies:

- lua 5.1
- sdl
- freetype2
- libungif

Compile the application's modules by running 'make'

It is possible to run the application on a PC. This requires installing extra packages:

-rw-r--r-- 1 root root     635 2009-09-30 10:01 libcurl3.list
-rw-r--r-- 1 root root    8070 2009-09-30 10:01 libldap2-dev.list
-rw-r--r-- 1 root root    3081 2009-09-30 10:01 libidn11-dev.list
-rw-r--r-- 1 root root   13470 2009-09-30 10:01 libcurl4-openssl-dev.list
-rw-r--r-- 1 root root    1946 2009-09-30 10:03 libilmbase-dev.list
-rw-r--r-- 1 root root    2350 2009-09-30 10:03 libgraphviz-dev.list
-rw-r--r-- 1 root root    4438 2009-09-30 10:03 libexif-dev.list
-rw-r--r-- 1 root root     975 2009-09-30 10:03 libdjvulibre-dev.list
-rw-r--r-- 1 root root     140 2009-09-30 10:03 libbz2-dev.list
-rw-r--r-- 1 root root    1090 2009-09-30 10:03 libwmf-dev.list
-rw-r--r-- 1 root root     367 2009-09-30 10:03 libtiffxx0c2.list
-rw-r--r-- 1 root root    2245 2009-09-30 10:03 libtiff4-dev.list
-rw-r--r-- 1 root root    1512 2009-09-30 10:03 librsvg2-dev.list
-rw-r--r-- 1 root root     976 2009-09-30 10:03 libjasper-dev.list
-rw-r--r-- 1 root root    3433 2009-09-30 10:03 libopenexr-dev.list
-rw-r--r-- 1 root root     350 2009-09-30 10:03 libopenexr6.list
-rw-r--r-- 1 root root    4443 2009-09-30 10:03 libmagick9-dev.list
-rw-r--r-- 1 root root    1057 2009-09-30 10:08 libslang2-dev.list
-rw-r--r-- 1 root root     448 2009-09-30 10:08 libartsc0-dev.list
-rw-r--r-- 1 root root    2789 2009-09-30 10:08 libaa1-dev.list
-rw-r--r-- 1 root root     679 2009-09-30 10:08 libdirectfb-extra.list
-rw-r--r-- 1 root root   15002 2009-09-30 10:08 libcucul-dev.list
-rw-r--r-- 1 root root     604 2009-09-30 10:08 libcaca-dev.list
-rw-r--r-- 1 root root    1342 2009-09-30 10:08 libasound2-dev.list
-rw-r--r-- 1 root root     873 2009-09-30 10:08 libsysfs-dev.list
-rw-r--r-- 1 root root    9201 2009-09-30 10:08 libdirectfb-dev.list
-rw-r--r-- 1 root root   20789 2009-09-30 10:08 libsdl1.2-dev.list
-rw-r--r-- 1 root root     481 2009-09-30 10:09 libgif-dev.list
-rw-r--r-- 1 root root     515 2009-09-30 10:10 libsdl-image1.2-dev.list
-rw-r--r-- 1 root root     321 2009-09-30 10:20 liblua5.1-curl0.list
-rw-r--r-- 1 root root     311 2009-09-30 13:19 lua5.1.list

Note that al lot of packages are just installed as dependency

Release
=============

Application software:
---------------------

All binaries are checked in into svn.
The binaries are built to ../app-binary

To release the application one has to do the following:


$ cd <cit-work-dir>
$ make clean
$ svn update
$ cd app
$ svn commit
$ make install		# this will build all binaries and copy them to ../app-binary
$ cd ../app-binary
$ svn commit		# the svn version of the application will compiled into sys.so
					# so that file HAS TO BE committed.

Only tag the release when the chinese have build and committed an the new release:

svn copy https://svn.saedra.nl/cit/trunk https://svn.saedra.nl/cit/tags/NQuire-n.m -m "Tagging release n.mRCx"

Building an image
-----------------

 cd <cit-work-dir>
 cd cit200-upgrade-tools/
 fakeroot make

The image can be found in cit200-upgrade-tools/release

There are two important images:

cit-app-*.image			# the application software build from the current app-binary (tar of app-binary)
cit-firmware-*.image	# the firmware including the last committed app-binary (jffs2 image file)

Install those images using ftp. Eg:

$ ftp <cit-ip-address> << EOF
put cit-app-*.image
bye
EOF


Configuration
=============

The configuration file cit.conf is read on startup, and re-written when the
application initialized or when changes are made to the configuration from the
web-interface. If the file does not exist at startup, it is automatically
generated.


Development
===========

When deveopping the cit-software, it is easy to mount you development directory using nfs:

mount --nolock 192.168.1.129:/home/maarten/workspace/NQuire/trunk/app /cit200/

Watch out deleting stuff on the cit, because it will actually be deleted in your workbrach.


Running 
=======

Connect the scanner to the first serial port /dev/ttyS0

Start the application by running 
 
$ cd /cit200 && lua ./main.lua

On startup, the application will attempt to configure the network according to
the settings found in the configuration database. The application will detect
and initialize the scanner, and warn if any error occurs while doing this.

To produce more verbose logging output, use the -l parameter

$ cd /cit200 && lua ./main.lua -l 5


For running the software on a pc the software should be compiled with arch=pc. 
This is also required for using some test en debugging tools in app/tools or app/test

Eg:

$ make clean; make arch=pc


Connecting
==========

There is a simple test script available (cit-test) to send test codes to the
application. Usage:

$ ./cit-test -h|{[-u] <ip adres> <test id>+}

Use -h a complete help on this tool

For example, to run test 2 over UDP, run

$ ./cit-test -u 192.168.1.200 2


Web interface
=============

The application can be reached using a web browser. The default port is port
80, but if this port can not be opened (for example when not running with root
permission), port 8000 will be used instead. 

To login on the web interface, use username 'admin' and password '1234'. The
password can be configured from /settings/system/pin_code


Source files
============

schema/			This directory contains the schema's for the configuration database
img/ 			Contains various images for fonts and web interface
base64.c		Base64 encoding/decoding, used for basic auth in webserver
beeper.lua		Beeper driver. Not yet functional on CIT due to hardware issues
beepthread.c	Separate process for driving beeper
config.lua		Configuration database management
config_node.lua	Configuration database management
display.lua		Generic display code
dpydrv_full.c	Full-featured display driver using truetype fonts
dpydrv_tiny.c	Simple display driver using fixed bitmap fonts
evq.lua			Event queue management
format.lua		Helper functions for formatting strings
getopt.lua		Getopt function for command line arguments
log.lua			Logging to console and/or syslog
main.lua*		Main application
net.c			Low-level network code for socket handling
network.lua		Network configuration for ethernet, GPRS and wifi
scanner.lua		Scanner handling
scanner_1d.lua
scanner_2d.lua
scanner_rf.lua
scanner_hid
cit.lua			CIT protocol implementation
sys.c			Some low-level helper functions and version info written in C
typecheck.lua	Typechecking for configuration database 
webserver.lua	Webserver implementation
webui.lua		CGI implementation for configuration web interface


