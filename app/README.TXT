
Introduction
============

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


Configuration
=============

The configuration file cit.conf is read on startup, and re-written when the
application initialized or when changes are made to the configuration from the
web-interface. If the file does not exist at startup, it is automatically
generated.


Running 
=======

Connect the scanner to the first serial port /dev/ttyS0

Start the application by running 
 
 ./main.lua

On startup, the application will attempt to configure the network according to
the settings found in the configuration database. The application will detect
and initialize the scanner, and warn if any error occurs while doing this.

To produce more verbose logging output, use the -l parameter

 ./main.lua -l5


Connecting
==========

There is a simple test script available (cit-test) to send test codes to the
application. Usage:

 ./cit-test <udp|tcp> <test_nr>

For example, to run test 2 over UDP, run

 ./cit-test udp 2

Note that the test script always connects to localhost 127.0.0.1. Adjust the
address in the script to test on other addresses.


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
beepthread.c		Separate process for driving beeper
config.lua		Configuration database management
config_node.lua		Configuration database management
display.lua		Generic display code
dpydrv_full.c		Full-featured display driver using truetype fonts
dpydrv_tiny.c		Simple display driver using fixed bitmap fonts
evq.lua			Event queue management
format.lua		Helper functions for formatting strings
getopt.lua		Getopt function for command line arguments
log.lua			Logging to console and/or syslog
main.lua*		Main application
net.c			Low-level network code for socket handling
network.lua		Network configuration for ethernet, GPRS and wifi
scanner.lua		Scanner handling
cit.lua			CIT protocol implementation
sys.c			Some low-level helper functions written in C
typecheck.lua		Typechecking for configuration database 
webserver.lua		Webserver implementation
webui.lua		CGI implementation for configuration web interface


