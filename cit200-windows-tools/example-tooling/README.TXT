==========
README.txt
==========

Author: M.R. van Dootingh
Date: febr 5 2010

============
Introduction
============

The example tooling consists of three tools:

nquire-server.exe         small simple server program (UDP based)
nquire-cmd.exe            send escape commands to an nquire
nquire-discover.exe       discover available nquires

All three programs are commandline programs.

To use the programs in windows:
 - first start a command shell (open start-menu, then type cmd.exe)
 - change the directory to where the programs are
 - type the name of the program with the required options 

e.g.

nquire-discover.exe -h

Would show how to use the nquire-discover program.

Although the programs are fully functional they are meant as examples only:
the source code can be used as reference code for how to connect to the nquire.

=====
Usage nquire-server.exe
=====

The barcodes have to be defined in a file named barcodes.ini, whereas the 
formatting has to be defined in a file named formats.ini
The directory for those files should be the current directory, or

Usage of the program is from the commandline, e.g.:

c:\> nquire-server-demo.exe "-db=c:\Documents and Settings\All Users" 
     -log=c:\tmp\nquire-server.log

Means that the formats.ini and barcodes.ini are expected in directory 
"c:\Documents and Settings\All Users" and that logging is done in file
c:\tmp\nquire-server.log
Use quotes as in the example when there are spaces the in directory-names.

Use option -h for help.
E.g.:

c:\> nquire-server.exe -h
 
The example formats.ini and barcodes.ini files describe the contents of those
files.

========================
Building the application
========================

The applications are distributed compiled for windows, with source 
for compiling the applications. 

The source can be compiled on linux and windows. 
Compiling on windows requires installing mingw.
Then compile with:

make

clean up 

