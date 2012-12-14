
ifneq ($(KERNELRELEASE),)

obj-m 	+= uc1698-fb.o

else

export KDIR		:= ~/tmp/eddy/linux-2.6.27.2-at91-eddy2
export PATH		:= $(PATH):/opt/lemonix/cdt/bin/
export ARCH		:= arm
export CROSS_COMPILE	:= arm-linux-

all:
	make -C $(KDIR) SUBDIRS=`pwd` 

clean:
	rm -rf *.o *.ko *.order *.symvers *.mod.c .*cmd .tmp_versions

endif

