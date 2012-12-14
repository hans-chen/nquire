==========
README.txt
==========

Author: M.R. van Dootingh
Date: febr 5 2010

============
Introduction
============

The nquire server demo is commandline program dat can be used as a server
for the nquire when only fixed barcodes are used.
The source code can be used as a reference for development of a more 
complex server.

=====
Usage
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

c:\> nquire-server-demo.exe -h
 
The example formats.ini and barcodes.ini files describe the contents of those
files.

========================
Building the application
========================

The application can be compiled in windows and in linux.
Eclipse c++ is used for windows development.
Makefiles are used for linux development.
Only in linux one can execute the tests.

=============================
Barcode identifier references
=============================

When defining barcodes, one should specify the barcode including the barcode
type identifier:

Barcode  Identifier Barcode Identifier 
EAN-8          FF
Codabar        % 
EAN-13         F
Code 93        c 
Code128        #
MSI Plessey    m 
EAN128         P
PDF417         r 
IF 2/5         i
QR Code        s
Code39         *
Aztec          z
GS1 Databar    R
DataMatrix     u
