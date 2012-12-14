# doc/app/img/Makefile
#
# Makefile for generating images from svg or barcode-text-content
# The barcodes are generated with the free-open-source tool: zint
# This can be downloaded from: http://sourceforge.net/projects/zint/

SHELL = bash
SVG = 

CODE128_BARCODES = \
	show-config.png \
	reboot.png \
	restore-defaults.png \
	set-serial.png \
	serial-EI00000.png \
	serial-EI4316002P.png \
	anounce_settings.png \
	enter_programming_mode.png \
	exit_programming_mode.png \
	set_dhcp_false.png \
	set_dhcp_true.png \
	set_interface_ethernet.png \
	set_interface_gprs.png \
	set_interface_wifi.png \
	45612348973.png \
	secret.png \
	user_is_jan.png \

QR_CODE_BARCODES = \
	network_interface_ethernet_2d.png \
	set_interface_wifi_2d.png \
	network_dhcp_false_2d.png \
	network_dhcp_true_2d.png \
	network_static_client_129.png \
	network_static_server_129.png \
	loglevel_5.png \
	loglevel_3.png \
	1d_and_2d.png \
	auth_on_piet_puck.png \
	long.png \

user_is_jan.png_TXT = **user=jan**
show-config.png_TXT = 020702
reboot.png_TXT = 020700
restore-defaults.png_TXT = 020701
set-serial.png_TXT = 020704
serial-EI00000.png_TXT = EI00000
serial-EI4316002P.png_TXT = EI4316002P
anounce_settings.png_TXT = 020705
enter_programming_mode.png_TXT = %\#\$$^*%
exit_programming_mode.png_TXT = %*^\$$\#%
secret.png_TXT = secret
set_dhcp_false.png_TXT = /network/dhcp = false
set_dhcp_true.png_TXT = /network/dhcp = true
set_interface_ethernet.png_TXT = /network/interface = ethernet
set_interface_gprs.png_TXT = /network/interface = gprs
set_interface_wifi.png_TXT = /network/interface = wifi
set_interface_wifi_2d.png_TXT = /network/interface = wifi
45612348973.png_TXT = 45612348973
1d_and_2d.png_TXT = /dev/scanner/barcodes = \"1D and 2D\" \
	/dev/scanner/enable-disable/PDF417 = true \
	/dev/scanner/enable-disable/QR_Code = true \
	/dev/scanner/enable-disable/Aztec = true \
	/dev/scanner/enable-disable/DataMatrix = true \

network_interface_ethernet_2d.png_TXT = /network/interface = ethernet
network_dhcp_false_2d.png_TXT = /network/dhcp = false
network_dhcp_true_2d.png_TXT = /network/dhcp = true
network_static_client_129.png_TXT = /network/dhcp = false; /cit/loglevel = 5; /cit/remote_ip = 192.168.1.129; /cit/mode = client;
network_static_server_129.png_TXT = /network/dhcp = false /cit/loglevel = 5 /cit/remote_ip = 192.168.1.129 /cit/mode = server
loglevel_5.png_TXT = /cit/loglevel = 5
loglevel_3.png_TXT = /cit/loglevel = 3

auth_on_piet_puck.png_TXT = /dev/auth/enable = true ;\
	/dev/auth/username = \"piet\" ;\
	/dev/auth/encrypted = \"BwVYu14F3zRDalosNitNU/\"
	
long.png_TXT = 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz\
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz\
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz\
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz\
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz

ALL	:= $(SVG:.svg=.png) $(CODE128_BARCODES) $(QR_CODE_BARCODES)

all: $(ALL)

debug:
	@echo "network_static_client_129.png_TXT='$(network_static_client_129.png_TXT)'"

%.png: %.svg
	inkscape --export-png=$@ $^

clean:
	rm -f $(ALL)

clobber: clean

$(CODE128_BARCODES): Makefile
	zint -o $@ --data="$($(@:%=%_TXT))"

$(QR_CODE_BARCODES): Makefile
	zint -o $@ --barcode=58 --data="$($(@:%=%_TXT))"

types:
	zint -o 2_5-Standard.png --barcode=2 --data=1234567890
	zint -o interleaved_2of5.png --barcode=3 --data=1234567890
	zint -o 2_5-Matrix.png --barcode=4 --data=1234567890 # is this type correct?
	zint -o 2_5-Industrial.png  --barcode=7 --data=1234567890

