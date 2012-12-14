#!/bin/bash

cit_ip="`nquire-discover -1 -n=3`"

ACK="\x06"

if test -z $cit_ip; then
	cit_ip="192.168.1.200"
fi

while true; do

	data="`nquire-cmd.exe -ip=$cit_ip -answer=1`"
	echo "Received event: $data"
	if [[ "$data" =~ ^MF ]]; then
		cardnum="`echo -n "$data" | cut -c3-10`"
		echo "Mifare event: cardnum=$cardnum"
		
		nquire-cmd.exe -ip=$cit_ip '-msg=\e\x42\x30\e\x24\e\x2e\x31\nWriting data...\n\nPlease keep card\nat terminal\x03'
		
		#sleep 1
		
		# writing sector:
		result="`nquire-cmd.exe -ip=$cit_ip -answer=1 \"-msg=\\e\\xf9${cardnum},123:KffffffffffffWf1BOepsie daisy now\\x03\"`"
		#echo "Write result = $result"
		echo -n "$result" | od -t x1
		
		if test "`echo -n $result | od -t x1 | head -1`" = "0000000 06"; then
			# reading what is just written:
			echo "Ok, reading written data..."
			answer=`nquire-cmd.exe -answer=1 -ip=$cit_ip "-msg=\\e\\xf8${cardnum},ffffffffffff:f1B\\x03"`
			echo $answer
			echo -n "$answer" | od -t x1
			
			# and signal end of transaction:
			nquire-cmd.exe -ip=$cit_ip '-msg=\e\x5e\e\x42\x30\e\x24\e\x2e\x31\nSuccess\n\nThank you\x03'
		else
			echo "Foutje..."
			nquire-cmd.exe -ip=$cit_ip '-msg=\e\x42\x30\e\x24\e\x2e\x31\nError\n\nPlease try again\x03'
		fi
		
	else
		echo "ignored"
	fi

done

