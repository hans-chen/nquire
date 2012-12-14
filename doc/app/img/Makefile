# doc/app/img/Makefile
#
# Makefile for generating images from svg or barcode-text-content
# The barcodes are generated with the free-open-source tool: zint
# This can be downloaded from: http://sourceforge.net/projects/zint/

SHELL = bash
SVG = 

CODE128_BARCODES = \
	show-config \
	reboot \
	restore-defaults \
	set-serial \
	env_diagnostic \
	serial-EI00000 \
	serial-EI4316002P \
	anounce_settings \
	enter_programming_mode \
	exit_programming_mode \
	set_dhcp_false \
	set_dhcp_true \
	set_interface_ethernet \
	set_interface_gprs \
	set_interface_wifi \
	45612348973 \
	secret \
	user_is_jan \
	network_dhcp_true \
	loglevel_5 \
	loglevel_4 \
	loglevel_3 \

QR_CODE_BARCODES = \
	network_interface_ethernet \
	set_interface_wifi \
	network_dhcp_false \
	network_dhcp_true \
	network_static_client_100 \
	network_static_server_100 \
	loglevel_5 \
	loglevel_4 \
	loglevel_3 \
	1d_and_2d \
	auth_on_piet_puck \
	long \

user_is_jan_TXT = **user=jan**
reboot_TXT = 020700
restore-defaults_TXT = 020701
show-config_TXT = 020702
set-serial_TXT = 020704
anounce_settings_TXT = 020705
env_diagnostic_TXT = 020706

serial-EI00000_TXT = EI00000
serial-EI4316002P_TXT = EI4316002P
enter_programming_mode_TXT = %\#\$$^*%
exit_programming_mode_TXT = %*^\$$\#%
secret_TXT = secret
set_dhcp_false_TXT = /network/dhcp = false
set_dhcp_true_TXT = /network/dhcp = true
set_interface_ethernet_TXT = /network/interface = ethernet
set_interface_gprs_TXT = /network/interface = gprs
set_interface_wifi_TXT = /network/interface = wifi
set_interface_wifi_TXT = /network/interface = wifi
45612348973_TXT = 45612348973
1d_and_2d_TXT = /dev/scanner/barcodes = \"1D and 2D\" \
	/dev/scanner/enable-disable/PDF417 = true \
	/dev/scanner/enable-disable/QR_Code = true \
	/dev/scanner/enable-disable/Aztec = true \
	/dev/scanner/enable-disable/DataMatrix = true \

network_interface_ethernet_TXT = /network/interface = ethernet
network_dhcp_false_TXT = /network/dhcp = false
network_dhcp_true_TXT = /network/dhcp = true
network_static_client_100_TXT = /network/dhcp = false; /cit/loglevel = 5; /cit/remote_ip = 192.168.1.100; /cit/mode = client;
network_static_server_100_TXT = /network/dhcp = false /cit/loglevel = 5 /cit/remote_ip = 192.168.1.100 /cit/mode = server
loglevel_5_TXT = /cit/loglevel = 5
loglevel_4_TXT = /cit/loglevel = 4
loglevel_3_TXT = /cit/loglevel = 3

auth_on_piet_puck_TXT = /dev/auth/enable = true ;\
	/dev/auth/username = \"piet\" ;\
	/dev/auth/encrypted = \"BwVYu14F3zRDalosNitNU/\"
	
long_TXT = 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz\
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz\
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz\
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz\
0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghjiklmnopqrstuvwxyz

ALL	:= $(SVG:.svg=.png) \
	$(CODE128_BARCODES:%=CODE128_%.png) \
	$(QR_CODE_BARCODES:%=QR_CODE_%.png)

all: $(ALL) types

debug:
	@echo "network_static_client_100_TXT='$(network_static_client_100_TXT)'"
	@echo "ALL=$(ALL)"

%.png: %.svg
	inkscape --export-png=$@ $^

clean:
	rm -f $(ALL) 2_5-Standard.png interleaved_2_of_5.png 2_5-Matrix.png 2_5-Industrial.png ITF14.png

clobber: clean

$(CODE128_BARCODES:%=CODE128_%.png): Makefile
	zint -o $@ --data="$($(@:CODE128_%.png=%_TXT))"

$(QR_CODE_BARCODES:%=QR_CODE_%.png): Makefile
	zint -o $@ --barcode=58 --data="$($(@:QR_CODE_%.png=%_TXT))"

types:
	#zint -o 2_5-Standard.png --barcode=2 --data=1234567890
	#zint -o interleaved_2_of_5.png --barcode=3 --data=1234567890
	#zint -o 2_5-Matrix.png --barcode=4 --data=1234567890 # is this type correct?
	#zint -o 2_5-Industrial.png  --barcode=7 --data=1234567890
	#zint -o ITF14.png  --barcode=89 --data=1234567890123
	zint -o Code128.png --barcode=20 --data=Code128
	zint -o UCC_EAN-128.png --barcode=16 --data="[01]95012345678903[3103]000123"
	zint -o EAN-8.png --barcode=13 --data=0808080 # ean 8 is ean with 7 digits
	zint -o EAN-13.png --barcode=13 --data=131313131312 # ean 13 is ean with 12 digits
	zint -o UPC-E.png --barcode=37 --data=123456 # 6 digits required
	zint -o UPC-A.png --barcode=34 --data=12345678901 # 11 digits required
	zint -o Interleaved-2_of_5.png --barcode=3 --data=1234567890
	zint -o Code39.png --barcode=8 --data=1234567890
	zint -o Codabar.png --barcode=18 --data=A1234567890B
	zint -o Code93.png --barcode=25 --data=1234567890
	zint -o PDF417.png --barcode=55 --data=1234567890
	zint -o QR_Code.png --barcode=58 --data=1234567890
	zint -o Aztec.png --barcode=92 --data=1234567890
	zint -o DataMatrix.png --barcode=71 --data=1234567890
	#zint -o Chinese-Sensible.png --barcode= --data=1234567890
	zint -o GS1_Databar.png --barcode=30 --data=12345678901
	zint -o ISBN.png --barcode=69 --data=9781234567897
	zint -o Code-11.png --barcode=1 --data=1234567890
	zint -o 2_5-Matrix.png --barcode=2 --data=1234567890 #?
	zint -o ITF14.png --barcode=89 --data=1234567890123
	# can't generate plessey: so it is checked in
	zint -o MSI-Plessey.png --barcode=47 --data=1234567890
	zint -o UK-Plessey.png --barcode=86 --data=963742312
	zint -o 2_5-Standard.png --barcode=2 --data=126498153
	zint -o 2_5-IATA.png --barcode=4 --data=126498153
	zint -o 2_5-Industrial.png --barcode=7 --data=4587232323

