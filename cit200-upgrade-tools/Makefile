#
# Copyright (c) 2009 Fujian Newland Computer Co., Ltd All Rights Reserved
#
# Cramfs Makefile
# author:	 Masm
# date	:	 2009-08-10
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

IMAGE_ROOTFS		:=	$(PATH_SRC)/rootfs.cramfs
IMAGE_APPFS			:=	$(PATH_SRC)/appfs.jffs2
IMAGE_CIT			:=	$(PATH_SRC)/cit200.image
IMAGE_CIT_EUROPE	:=	cit200-noselftest.image
IMAGE_BOOTM			:=	$(PATH_SRC)/kernel.cit200.bootm
IMAGE_EM2027_KERNEL	:=	$(PATH_SRC)/em2027_kernel.bin
IMAGE_EM207_APP		:=	$(PATH_SRC)/em2027_app.bin
SRC_KERNEL 			:=	$(PATH_SRC)/kernel.cit200
SRC_LOGO 			:=	$(PATH_SRC)/nl_logo.bmp
TOOLS_MKJFFS2 		:=	$(PATH_TOOLS)/mkfs.jffs2
TOOLS_MKIMAGE		:=	$(PATH_TOOLS)/mkimage
TOOLS_PACK			:=	$(PATH_TOOLS)/host_pack_tar.sh


##################################################################
#	image version					    <------	config them
##################################################################
VERSION_APP		:= 1.3
VERSION_ROOTFS		:= 1.0
VERSION_KERNEL		:= 2.6.27.2
VERSION_FIRMWARE	:= 1.2
VERSION_LOGO		:= 1.0
VERSION_EM2027_KRL	:= 3.05.024
VERSION_EM2027_APP	:= 3.01.013

LOGFILE				:= upgrade_log.txt
##################################################################
#	main
##################################################################

all:build_image build_release
	@echo "finish."
build_image:
	-@rm -v $(IMAGE_CIT)
	@echo "-------------------------------------------"
	@dd if=$(SRC_KERNEL) of=$(IMAGE_CIT) bs=64K 
	@echo -------------------------------------------
	@dd if=$(SRC_LOGO) of=$(IMAGE_CIT) seek=26 bs=64k 
	@echo -------------------------------------------
	@dd if=$(IMAGE_ROOTFS) of=$(IMAGE_CIT) seek=27 bs=64k 
	@echo -------------------------------------------
	@dd if=$(IMAGE_APPFS) of=$(IMAGE_CIT) seek=83 bs=64k 
	@echo -------------------------------------------
	@chmod 777 $(IMAGE_CIT)

build_bootm:
	-@rm -v $(IMAGE_BOOTM)
	@$(TOOLS_MKIMAGE) -n "CIT KERNEL" -A arm -O linux -T kernel -C none -a 0x20500000 -e 0x20500040 -d $(SRC_KERNEL) $(IMAGE_BOOTM)

build_release:
	-@rm -v $(PATH_RELEASE)/*.image
	@echo -en "-----------------------------------------------------------\n" >> $(LOGFILE)
	@echo -en $(shell date) "\n" >> $(LOGFILE)
	@echo -en "CIT application version:\t" $(VERSION_APP) "\n" >> $(LOGFILE)
	@echo -en ""

	-@rm -rf $(PATH_SRC)/app-binary > /dev/null 2>&1
	@cp -a $(PATH_SVN)/app-binary $(PATH_SRC)/	
	@cd $(PATH_SRC)/app-binary
	@find $(PATH_SRC)/app-binary -name ".svn" -type d | xargs rm -rf
	@cd $(PATH_PWD)
	@$(TOOLS_PACK) -s $(PATH_SRC)/app-binary -v $(VERSION_APP)
	@rm -rf $(PATH_SRC)/app-binary

	@echo -en "\n" >> $(LOGFILE)
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
	@echo -en "CIT em2027 kernel version:\t" $(VERSION_EM2027_KRL) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -e $(IMAGE_EM2027_KERNEL) -v $(VERSION_EM2027_KRL)
	

	@echo -en "\n" >> $(LOGFILE)
	@echo -en "CIT em2027 app version:\t" $(VERSION_EM2027_APP) "\n" >> $(LOGFILE)
	@$(TOOLS_PACK) -m $(IMAGE_EM207_APP) -v $(VERSION_EM2027_APP)

clean:
	@rm -v $(PATH_RELEASE)/*

