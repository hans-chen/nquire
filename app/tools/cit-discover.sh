#!/bin/sh

if test -z $1; then
	DEST=239.255.255.250
else
	DEST=$1
fi

# get the sudo password
sudo echo Starting discovery

# capture first 2 matching packets (discover request and response for 1 nquire):
#sudo tcpdump -A -s 0 -c 2 -n -i eth0 udp port 19200 &

# wait for tcpdump to start
#sleep 1

echo "=== Start discover================="

netcat -q 1 -u -b $DEST 19200 << EOF
CIT-DISCOVER-REQUEST
Version:	1
RESPONSE-TO-SENDER-PORT
EOF

echo "=== End discover =================="


