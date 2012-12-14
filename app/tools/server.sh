#!/bin/bash 
#
# this is not a real server: it just dumps all received data to the screen.
#
# args: 
#	$1	optional ipaddres (otherwise the address in file .cit.ip
# 

CIT_IP_FILE=.cit.ip

function help()
{
    echo "usage: put [<ip>]"
	echo "When ip is omitted, the content of file ./$CIT_IP_FILE is used"
}

if test -z "$1"; then
	if test -f $CIT_IP_FILE; then
		IP=`cat $CIT_IP_FILE`
	else
		help
	    exit -1
	fi		
else
	IP=$1
fi

if ping -c 1 $IP; then
    CIT=$IP
	echo $IP > $CIT_IP_FILE
else
	help
    exit -1
fi

nc -w1 $CIT 9101 | hexdump -C


