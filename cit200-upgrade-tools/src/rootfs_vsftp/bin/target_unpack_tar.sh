#!/bin/sh
Program_Name=$0
Now_path=`pwd`
Pack_name="app"
Pack_version=1.0
Unpack_path=
Pack_file_path=
Pack_type="app"

Product="cit"
Component=
Version="0.1"
Md5sum=
Filetype=".image"
Message_clolorB="\033[37;1m"
Message_clolorE="\033[0m"
usage()
{
    cat <<EOF
	
Usage:  $Program_Name [OPTIONS]

Unpacking tool for cit200
  script will not calculate md5sum of the file.It should be check in the application.
  If any error happen, it will return 1.

  After update, it will remove the update image.
Options:
    -s FILE         Update the application from [FILE]:cit-app-0.2-91900cb5733b29855f9ee61d9578f6ba.image
    -k FILE         Update the kernel flash partition from [FILE]: cit-kernel-0.2-7ec8feff9530018bbeb6ed47292078dd.image
    -l FILE         Update the logo flash paratition from [FILE]: cit-logo-0.1-667419a7e2f8bbd7929cfec4d2ad47a1.image
    -r FILE         Update the rootfs flash paratition from [FILE]: cit-rootfs-0.2-85f2e768019421ac13904de3041b4fbe.image
    -f FILE         Update the firmware flash paratition from [FILE]:cit-firmware-0.2-ba9e7e39c8b64953bc4560b64a8e218b.image
                        firmware include kernel,logo,rootfs paratition.
    -e FILE         Update the em2027 kernel from [FILE]:cit-em2027kernel-3.05.024-120133fc25763fa3d2ccc1298461ba3a.image
    -m FILE         Update the em2027 application from [FILE]:cit-em2027app-3.01.013-01cbab5177223bb4d4d71d0d6d9a7dae.image	
                        Note: Before update,please close the usb scanner in application.
    -h              Show this usage guide.
Note:
    input file format:
    <product>-<component>-<version>-<md5sum>.image

example:
	$Program_Name -s cit-app-0.2-91900cb5733b29855f9ee61d9578f6ba.image
it will unpack cit-app-0.2-91900cb5733b29855f9ee61d9578f6ba.image on the /cit200

	$Program_Name -k cit-kernel-0.2-7ec8feff9530018bbeb6ed47292078dd.image
it will update the kernel flash partition.

	$Program_Name -l cit-logo-0.1-667419a7e2f8bbd7929cfec4d2ad47a1.image
it will update the logo flash partition.
        
	$Program_Name -r cit-rootfs-0.2-85f2e768019421ac13904de3041b4fbe.image
Before update the partition, it will umount /dev/root to change the root file system into read only mode.
it will update the rootfs flash partition.After done,it will reboot.

	$Program_Name -f cit-firmware-0.2-ba9e7e39c8b64953bc4560b64a8e218b.image
Before update the partition, it will umount /dev/root to change the root file system into read only mode.
it will udpate the kernel,logo,rootfs flash partition. After done,it will reboot.
	
	$Program_Name -e cit-em2027kernel-3.05.024-120133fc25763fa3d2ccc1298461ba3a.image
it will update the kernel of the usb scanner em2027.

	$Program_Name -m cit-em2027app-3.01.013-01cbab5177223bb4d4d71d0d6d9a7dae.image
it will update the application of the usb scanner em2027.

EOF
}
# main
if [ $# -lt 2 ] ; then
    usage
    exit 1
fi
# TODO Add long command line options.
while getopts "k:s:hl:r:f:e:m:" opt ; do
# set -e 
    case "$opt" in
        f)
			Pack_file_path=$OPTARG
            if [ -f $Pack_file_path ] ; then
                cp -a /bin/busybox /home/ftp/
                umount /
                dd if=$Pack_file_path of=/dev/mtdblock/2 skip=0 count=1664 bs=1024
                dd if=$Pack_file_path of=/dev/mtdblock/3 skip=1664 count=64 bs=1024
                dd if=$Pack_file_path of=/dev/mtdblock/4 skip=1728 count=6272 bs=1024
                echo "update the firmware succ!"
                echo "it will reboot....."
                /home/ftp/busybox reboot 
                exit 0
            fi
            exit 1
            ;;
        k)
            Pack_file_path=$OPTARG
            if [ -f $Pack_file_path ] ; then
                dd if=$Pack_file_path of=/dev/mtdblock/2
                if [ $? -eq 0 ] ; then
                    echo "update the kernel flash partition succ!"
                    rm -f $Pack_file_path
                    exit 0
                else
                    echo "update the kernel flash partition error!"
                    rm -f $Pack_file_path
                    exit 1
                fi
            else
                echo "can't open $Pack_file_path"
                exit 1
            fi
            exit 1
            ;;
        l)
            Pack_file_path=$OPTARG
            if [ -f $Pack_file_path ] ; then
                dd if=$Pack_file_path of=/dev/mtdblock/3
                if [ $? -eq 0 ] ; then
                    echo "update the logo flash partition succ!"
                    rm -f $Pack_file_path
                    exit 0
                else
                    echo "update the logo flash partition error!"
                    rm -f $Pack_file_path
                    exit 1
                fi
            else
                echo "can't open $Pack_file_path"
                exit 1
            fi
            exit 1
            ;;
        r)
            Pack_file_path=$OPTARG
            if [ -f $Pack_file_path ] ; then
                cp -a /bin/busybox /home/ftp/
                umount /
                dd if=$Pack_file_path of=/dev/mtdblock/4
                if [ $? -eq 0 ] ; then
                    echo "update the rootfs flash partition succ!"
                    echo "it will reboot"
                    /home/ftp/busybox reboot 
                    exit 0
                else
                    echo "update the rootfs flash partition error!"
                    /home/ftp/busybox reboot 
                    exit 1
                fi
            else
                echo "can't open $Pack_file_path"
                exit 1
            fi
            exit 1
            ;;
        s)
			Pack_file_path=$OPTARG
			Unpack_path="/cit200"
            ;;
		e) 
            Pack_file_path=$OPTARG
            if [ -f $Pack_file_path ] ; then
                /bin/cit_em2027_update -z kern -f $Pack_file_path
                if [ $? -eq 0 ] ; then
                    echo -e $Message_clolorB "update the kernel of the usb scanner em2027 succ!" $Message_clolorE
                    rm -f $Pack_file_path
                    exit 0
                else
                    echo -e $Message_clolorB "update the kernel of the usb scanner em2027 error!" $Message_clolorE
                    rm -f $Pack_file_path
                    exit 1
                fi
            else
                echo -e $Message_clolorB "can't open $Pack_file_path" $Message_clolorE
                exit 1
            fi
			;;
		m)
            Pack_file_path=$OPTARG
            if [ -f $Pack_file_path ] ; then
                /bin/cit_em2027_update -z appl -f $Pack_file_path
                if [ $? -eq 0 ] ; then
                    echo -e $Message_clolorB "update the application of the usb scanner em2027 succ!" $Message_clolorE
                    rm -f $Pack_file_path
                    exit 0
                else
                    echo -e $Message_clolorB "update the application of the usb scanner em2027 error!" $Message_clolorE
                    rm -f $Pack_file_path
                    exit 1
                fi
            else
                echo -e $Message_clolorB "can't open $Pack_file_path" $Message_clolorE
                exit 1
            fi
			;;
		h) 
			usage
			exit 1
			;;
        *)
            usage
            exit 1
            ;;
    esac
done
#upack tar package
#set -e
if [ ! -f $Pack_file_path ] ; then
    echo -en "can't open\t" $Package_path "\n"
    exit 1 
fi
if [ ! -d $Unpack_path ] ; then
   echo -en "can't locate \t" $Unpack_path  "\n"
   exit 1
fi 
tar -xf $Pack_file_path -C $Unpack_path
if [ $? -eq 0 ] ; then
    sync
    echo -en "unpack successful\n"
    rm -f $Pack_file_path
    exit 0
else
    echo -en "unpack fail\n"
    rm -f $Pack_file_path
    exit 1
fi
