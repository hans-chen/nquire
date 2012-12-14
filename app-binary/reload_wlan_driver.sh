#!/bin/sh

while true; do
	echo 3 > /sys/class/firmware/timeout
	ifconfig wlan0 up &
	echo 60 > /sys/class/firmware/timeout

	# wait for ifconfig to be started:
	sleep 1 

	# load firmware
	if test -d /sys/class/firmware/1-1.2:1.0; then
		echo 1 > /sys/class/firmware/1-1.2\:1.0/loading
		cat  /lib/firmware/rt73.bin > /sys/class/firmware/1-1.2\:1.0/data
		echo 0 > /sys/class/firmware/1-1.2\:1.0/loading
	fi
done
