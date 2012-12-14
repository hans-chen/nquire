#!/bin/bash 
#
# This is an example of how netcat can be used accept NQuire connections
# for testing the different connect modi of the nquire
#
# Usage: (TODO)
#   server.sh -h | { [-udp|-connect|-listen] [<ip>] }
#

CIT_IP_FILE=.cit.ip

UDP_PORT=9000
TCP_PORT=9101  

MODE="LISTEN"

set -x

function help()
{
    echo "usage: server.sh [-udp|-connect|-listen] [<ip>]"
	echo "default is -listen to incomming tcp connects" 
	echo "When ip is omitted, the content of file ./$CIT_IP_FILE is used"
}

if test -f $CIT_IP_FILE; then
	IP=`cat $CIT_IP_FILE`
fi

while ! test -z $1; do
	if test "$1" = "-udp"; then
		MODE="UDP"
	elif test "$1" = "-listen"; then
		MODE="LISTEN"
	elif test "$1" = "-connect"; then
		MODE="CONNECT";
	elif test "$1" = "-h"; then
		help
		exit 0
	else
		IP=$1
	fi
	shift
done

if ! test "$MODE" = "LISTEN"; then
	if ping -c 1 $IP; then
		echo $IP > $CIT_IP_FILE
	else
		echo "Could not ping Nquire" 1>&2
		help
		exit -1
	fi
fi

set -x

if test "$MODE" = "UDP"; then
	nc -u $IP $UDP_PORT
elif test "$MODE" = "LISTEN"; then
	nc -l -p $TCP_PORT
elif test "$MODE" = "CONNECT"; then
	nc $IP $TCP_PORT
fi



