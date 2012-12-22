#!/bin/sh

NQIP=192.168.1.200
NQFirmware=cit-firmware-1.6.1.build.r1104-1b8a89f86aba776969feffc67f55ab75.image
NQ2027Kernel=cit-em2027kernel-3.06.024.build.r940-2653e46e0d67ce9307bd8cebc4cf48ed.image
NQ2037App=cit-em2027app-1.01.002.build.r940-d3313468cbb6d905139af8e23c6d2537.image
NQ1300Kernel=cit-em1300kernel-1.31.28.build.r1111M-8c6c54cdabcfafa03574a843fb811193.image
UpTimeOut=160

while true
do
    echo -e "---------------------------------------------------------
Usage of NQuire upgrading tool
*******************************************************
\ta\t\tClear IP table
\tp\t\tPing NQuire 2 times
\tl\t\tBrowse the main page from NQuire to see version information
\tf\t\tUpgrade firmware
\t2k\t\tUpgrade EM2027 kernel
\t2a\t\tUpgrade EM2027 app
\t1k\t\tUpgrade EM1300 kernel
--------------------------------------------------------\n"
    read Input

    case $Input in
	"202") 
	    echo -e ">>>>>clean IP table"
	    sudo arp -d $NQIP
	    sleep 5
	    echo -e ">>>>>upgrade firmware"
	    ftp -u ftp://$NQIP/$NQFirmware ~/nq/$NQFirmware
	    sleep 180
	    echo -e ">>>>>upgrde 2D kernel"
	    ftp -u ftp://$NQIP/$NQ2027Kernel ~/nq/$NQ2027Kernel
	    sleep 120
	    echo ">>>>>upgrade 2D application"
	    ftp -u ftp://$NQIP/$NQ2037App ~/nq/$NQ2037App
	    sleep 100
	    echo ">>>>>The system information:"
	    w3m -dump http://192.168.1.200/?p=home | grep '^Serial\|[Ff]irmware' | sed 's/[A-z ]*1.6.1/Firmware..OK..V 1.6.1/; s/[0-9A-z\/ ]*1.01.002/2DAppVer..OK..V 1.01.002/g; s/ \/fw:3.06.024/\
2DKernel..OK..V 3.06.024/'
	    ;;
	"201")
	    echo -e ">>>>>clean IP table"
	    sudo arp -d $NQIP
	    sleep 5
	    echo -e ">>>>>upgrade firmware"
	    ftp -u ftp://$NQIP/$NQFirmware ~/nq/$NQFirmware
	    sleep 180
	    echo ">>>>>upgrade 1D kernel"
	    ftp -u ftp://$NQIP/$NQ1300Kernel ~/nq/$NQ1300Kernel
	    sleep 100
	    echo ">>>>>The system information:"
	    w3m -dump http://192.168.1.200/?p=home | grep '^Serial\|[Ff]irmware' | sed 's/[A-z ]*1.6.1/Firmware..OK..V 1.6.1/; s/[0-9A-z\/ ]*1.01.002/2DAppVer..OK..V 1.01.002/g'
	    ;;
	"a") sudo arp -d $NQIP;;
	"p") ping -c 2 $NQIP;;
	"l") w3m -dump http://192.168.1.200/?p=home | grep '^Serial\|[Ff]irmware' | sed 's/[A-z ]*1.6.1/Firmware..OK..V 1.6.1/; s/[0-9A-z\/ ]*1.01.002/2DAppVer..OK..V 1.01.002/g; s/ \/fw:3.06.024/\
2DKernel..OK..V 3.06.024/';;
	"f") ftp -u ftp://$NQIP/$NQFirmware ~/nq/$NQFirmware;;
	"2k") ftp -u ftp://$NQIP/$NQ2027Kernel ~/nq/$NQ2027Kernel;;
	"2a") ftp -u ftp://$NQIP/$NQ2037App ~/nq/$NQ2037App;;
	"1k") ftp -u ftp://$NQIP/$NQ1300Kernel ~/nq/$NQ1300Kernel;;
	"q") break;;
    esac
done
