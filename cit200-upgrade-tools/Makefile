#
# Copyright (c) 2011 Fujian Newland Computer Co., Ltd All Rights Reserved
#
# Cramfs Makefile
# author:	 cairy
# date	:	 2011-03-18
# mail	:	 cairy@newlandcomputer.com
#
#

##################################################################
#	PATH 								<------ config them
##################################################################

PATH_PWD			:=	$(shell pwd)
PATH_TFTP			:=	/tftproot
PATH_SVN			:=	$(PATH_PWD)/../
PATH_RELEASE		:=	$(PATH_PWD)/release
PATH_SRC			:=	$(PATH_PWD)/src
PATH_IMAGE			:=	$(PATH_PWD)/image
PATH_TOOLS			:=	$(PATH_PWD)/tools
PATH_ROOTFS			:=	$(PATH_SRC)/rootfs
PATH_APPFS			:=	$(PATH_SRC)/appfs
PATH_DATA			:=	$(PATH_SRC)/data
PATH_BUILD			:= 	$(PATH_PWD)/build/
PATH_NFS			:=	$(PATH_BUILD)/cit-rootfs/

IMAGE_ROOTFS		:=	$(PATH_SRC)/rootfs.cramfs
IMAGE_APPFS			:=	$(PATH_SRC)/appfs.jffs2
IMAGE_CIT			:=	$(PATH_IMAGE)/cit200.image
IMAGE_CIT_FACTORY := $(PATH_IMAGE)/cit200_factory.image
IMAGE_CIT_EUROPE	:=	cit200-noselftest.image
IMAGE_BOOTM			:=	$(PATH_IMAGE)/kernel.cit200.bootm
IMAGE_EM2027_KERNEL	:=	$(PATH_SRC)/em2027_kernel.bin
IMAGE_EM2027_APP	:=	$(PATH_SRC)/em2027_app.bin
IMAGE_EM1300_KERNEL :=	$(PATH_SRC)/em1300_kernel.bin
IMAGE_DATA			:= 	$(PATH_IMAGE)/data.jffs2
SRC_KERNEL 			:=	$(PATH_SRC)/kernel.cit200
SRC_KERNEL_NFS 		:=	$(PATH_SRC)/kernel.cit200.nfs
SRC_LOGO 			:=	$(PATH_SRC)/nl_logo.bmp
SRC_LOGO_M4 		:=	$(PATH_SRC)/nl_m4.bmp
SRC_DEVICETABLE		:= 	$(PATH_SRC)/device_table.txt
SRC_CIT200			:= 	$(PATH_PWD)/../app-binary
TOOLS_MKJFFS2 		:=	$(PATH_TOOLS)/mkfs.jffs2
TOOLS_MKIMAGE		:=	$(PATH_TOOLS)/mkimage
TOOLS_MKCRAMFS		:=	$(PATH_TOOLS)/mkcramfs
TOOLS_PACK			:=	$(PATH_TOOLS)/host_pack_tar.sh
TOOLS_BUILD_SCANNER := $(PATH_TOOLS)/buid_image_scanner.sh

FILE_NFS			:=	$(PATH_IMAGE)/cit-rootfs.tar
FILE_DEV			:=	$(PATH_SRC)/dev.tar


##################################################################
#	image version					    <------	config them
##################################################################
VERSION_APP			:= 2.0
VERSION_ROOTFS		:= 1.5.3
VERSION_KERNEL		:= 2.6.35.7
VERSION_FIRMWARE	:= 2.0
VERSION_LOGO		:= 1.0
VERSION_EM2027_KRL	:= 3.06.038
VERSION_EM2027_APP	:= 1.01.002
VERSION_EM1300_KRL	:= 1.35.28

LOGFILE				:= upgrade_log.txt
##################################################################
#	main
##################################################################

all:build_data build_image build_factory_image build_bootm build_releasex
	@echo "finish."
build_test:build_data build_rootfs build_appfs build_image build_factory_image build_bootm build_releasex
	@echo "finish."


build_nfs:
	@echo "Making nfs tar...."
	@rm -rf $(FILE_NFS)
	@rm -rf $(PATH_NFS)/
	@mkdir -p $(PATH_NFS)/
	@cp -a $(PATH_ROOTFS)/* $(PATH_NFS)/
	@cp -a $(PATH_APPFS)/ $(PATH_NFS)/
	@find $(PATH_NFS)/ -type d -name ".svn" | xargs rm -rf
	@cd $(PATH_NFS)/../ && tar cvf $(FILE_NFS) cit-rootfs/
	@cp -av $(FILE_DEV) $(PATH_IMAGE)/
	@echo "You need use root users to tar xvf $(FILE_DEV) in nfs directory(cit-rootfs)"

build_rootfs:
	@echo "Making cramfs disk image...."
	-@rm -f $(IMAGE_ROOTFS)
	-@rm -rf $(PATH_BUILD)/rootfs
	@cp -a $(PATH_ROOTFS) $(PATH_BUILD)/
	@chmod 777 $(PATH_BUILD)/rootfs/home
	@chmod 777 $(PATH_BUILD)/rootfs/bin/busybox
	@chmod 777 $(PATH_BUILD)/rootfs/home/ftp
	@chmod 777 $(PATH_BUILD)/rootfs/home/cit
	@chmod 777 $(PATH_BUILD)/rootfs/home/nobody
	@find $(PATH_BUILD)/rootfs/ -type d -name ".svn" | xargs rm -rf
	@$(TOOLS_MKCRAMFS)  -q -D $(SRC_DEVICETABLE) $(PATH_BUILD)/rootfs $(IMAGE_ROOTFS)
	@chmod 777 $(IMAGE_ROOTFS)
	@echo "done...."

build_appfs:
	@echo "Build appfs partition image..."
	-@rm -f $(IMAGE_APPFS)
	-@rm -rf $(PATH_BUILD)/appfs
	@cp -a $(PATH_APPFS) $(PATH_BUILD)/
	@find $(PATH_BUILD)/appfs -type d -name ".svn" | xargs rm -rf
	@$(TOOLS_MKJFFS2)  -q -D $(SRC_DEVICETABLE) -r $(PATH_BUILD)/appfs -o $(IMAGE_APPFS) -e 0x10000 --pad=0x250000 -n	
	@chmod 777 $(IMAGE_APPFS)
	@echo "done...."

build_appfs_svn:
	@echo "Build appfs partition image..."
	-@rm -f $(IMAGE_APPFS)
	-@rm -rf $(PATH_BUILD)/appfs
	@mkdir -p $(PATH_BUILD)
	@cp -a $(PATH_APPFS) $(PATH_BUILD)/
	@cp -av $(SRC_CIT200) $(PATH_BUILD)/appfs/cit200
	@find $(PATH_BUILD)/appfs -type d -name ".svn" | xargs rm -rf
	@$(TOOLS_MKJFFS2)  -q -D $(SRC_DEVICETABLE) -r $(PATH_BUILD)/appfs -o $(IMAGE_APPFS) -e 0x10000 --pad=0x250000 -n	
	@chmod 777 $(IMAGE_APPFS)
	@echo "done...."

build_data:
	@echo "Build data partition image..."
	-@rm -f $(IMAGE_DATA)
	-@rm -rf $(PATH_BUILD)/data
	@mkdir -p $(PATH_BUILD)
	@cp -a $(PATH_DATA) $(PATH_BUILD)/
	@find $(PATH_BUILD)/data -type d -name ".svn" | xargs rm -rf
	@$(TOOLS_MKJFFS2)  -r $(PATH_BUILD)/data -o $(IMAGE_DATA) -e 0x10000 --pad=0x50000 -n	
	@chmod 777 $(IMAGE_DATA)

build_image:
	@rm -f $(IMAGE_CIT)
	@echo "-------------------------------------------"
	@dd if=$(SRC_KERNEL) of=$(IMAGE_CIT) bs=64K 
	@echo -------------------------------------------
	@dd if=$(SRC_LOGO) of=$(IMAGE_CIT) seek=52 bs=32k 
	@echo -------------------------------------------
	@dd if=$(SRC_LOGO_M4) of=$(IMAGE_CIT) seek=53 bs=32k 
	@echo -------------------------------------------
	@dd if=$(IMAGE_ROOTFS) of=$(IMAGE_CIT) seek=27 bs=64k 
	@echo -------------------------------------------
	@dd if=$(IMAGE_APPFS) of=$(IMAGE_CIT) seek=83 bs=64k 
	@echo -------------------------------------------
	@dd if=$(IMAGE_DATA) of=$(IMAGE_CIT) seek=120 bs=64k 
	@echo -------------------------------------------
	@chmod 777 $(IMAGE_CIT)

build_factory:build_data build_factory_image build_bootm build_releasex 
	@echo "done...."


build_factory_image:
	@rm -f $(IMAGE_CIT_FACTORY)
	@echo "-------------------------------------------"
	@dd if=$(SRC_KERNEL) of=$(IMAGE_CIT_FACTORY) bs=64K 
	@echo -------------------------------------------
	@dd if=$(SRC_LOGO) of=$(IMAGE_CIT_FACTORY) seek=52 bs=32k 
	@echo -------------------------------------------
	@dd if=$(SRC_LOGO_M4) of=$(IMAGE_CIT_FACTORY) seek=53 bs=32k 
	@echo -------------------------------------------
	@dd if=$(IMAGE_ROOTFS) of=$(IMAGE_CIT_FACTORY) seek=27 bs=64k 
	@echo -------------------------------------------
	@dd if=$(IMAGE_APPFS) of=$(IMAGE_CIT_FACTORY) seek=83 bs=64k 
	@echo -------------------------------------------
	@dd if=$(IMAGE_DATA) of=$(IMAGE_CIT_FACTORY) seek=120 bs=64k 
	@echo -------------------------------------------
	$(TOOLS_BUILD_SCANNER) $(IMAGE_EM2027_KERNEL) "EM2027KERNEL" $(VERSION_EM2027_KRL) $(IMAGE_CIT_FACTORY)
	$(TOOLS_BUILD_SCANNER) $(IMAGE_EM2027_APP) "EM2027APP" $(VERSION_EM2027_APP) $(IMAGE_CIT_FACTORY)
	$(TOOLS_BUILD_SCANNER) $(IMAGE_EM1300_KERNEL) "EM1300KERNEL" $(VERSION_EM1300_KRL) $(IMAGE_CIT_FACTORY)
	@chmod 777 $(IMAGE_CIT_FACTORY)

build_bootm:
	@rm -f $(IMAGE_BOOTM)
	@$(TOOLS_MKIMAGE) -n "CIT KERNEL" -A arm -O linux -T kernel -C none -a 0x20500000 -e 0x20500040 -d $(SRC_KERNEL_NFS) $(IMAGE_BOOTM)
	@chmod 777 $(IMAGE_BOOTM)

build_releasex:
	@rm -f $(PATH_RELEASE)/*.image
	@echo -en "-----------------------------------------------------------\n" >> $(LOGFILE)
	@echo -en $(shell date) "\n" >> $(LOGFILE)
	@echo -en "CIT application version:\t" $(VERSION_APP) "\n" >> $(LOGFILE)
	@echo -en ""
	@echo -en "\n" >> $(LOGFILE)

	@$(TOOLS_PACK) -s $(PATH_PWD)/../app-binary -v $(VERSION_APP)

	@echo -en "CIT kernel version:\t" $(VERSION_KERNEL) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -k $(SRC_KERNEL) -v $(VERSION_KERNEL)

	@echo -en "\n" >> $(LOGFILE)
	@echo -en "CIT logo version:\t" $(VERSION_LOGO) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -l $(SRC_LOGO) -v $(VERSION_LOGO)

	@echo -en "\n" >> $(LOGFILE)
	@echo -en "CIT rootfs version:\t" $(VERSION_ROOTFS) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -r $(IMAGE_APPFS) -v $(VERSION_ROOTFS)

	@echo -en "\n" >> $(LOGFILE)
	@echo -en "CIT firmware version:\t" $(VERSION_FIRMWARE) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -f $(IMAGE_CIT) -v $(VERSION_FIRMWARE)

	@echo -en "\n" >> $(LOGFILE)
	@echo -en "CIT factory firmware version:\t" $(VERSION_FIRMWARE) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -g $(IMAGE_CIT_FACTORY) -v $(VERSION_FIRMWARE)
	
	@echo -en "\n" >> $(LOGFILE)
	@echo -en "CIT em2027 kernel version:\t" $(VERSION_EM2027_KRL) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -e $(IMAGE_EM2027_KERNEL) -v $(VERSION_EM2027_KRL)
	

	@echo -en "\n" >> $(LOGFILE)
	@echo -en "CIT em2027 app version:\t" $(VERSION_EM2027_APP) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -m $(IMAGE_EM2027_APP) -v $(VERSION_EM2027_APP)

	@echo -en "\n" >> $(LOGFILE)
	@echo -en "CIT em1300 kernel version:\t" $(VERSION_EM1300_KRL) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -d $(IMAGE_EM1300_KERNEL) -v $(VERSION_EM1300_KRL)

clean:
	@rm -rfv $(PATH_RELEASE)/*
	@rm -fv $(PATH_IMAGE)/*
	@rm -frv $(PATH_BUILD)/*

