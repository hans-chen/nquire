/***********README**********/

kernel.cit200  		----compressed kernel
usb-datapipe.ko 	----scanner driver	

uboot cmd:		
							----download kernel
tftpboot 0x20000000 kernel.cit200; erase 0x10020000 0x1019ffff; cp.b 0x20000000 0x10020000 0x180000
							----set kernel boot cmd
setenv bootcmd 'cp.b 0x10020000 0x20500000 0x180000; go 0x20500000'
saveenv