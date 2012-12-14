#!/bin/bash 
#if [ "$(whoami)" != 'root' ]; then
#   echo "You have no permission to run $0 as non-root user."
#   exit 1;
#fi
Program_Name=$0
Now_path=`pwd`
Pack_path=

Product="cit"
Component=
Version="0.1"
Md5sum=
Filetype=".image"

#Install_path=$Now_path
Install_path=$Now_path"/release"

BuildVersion=""
# usage
usage()
{
    cat <<EOF
	
	
Usage:  $Program_Name [OPTIONS]

Packing tool for cit200
Options:
    -s PATH             Pack the application for cit200. 
    -k FILE             Pack a kernel_image_file.
    -l FILE             Pack logo.bmp into logo image.(size: 32KByte)
    -r FILE             Pack rootfs.jffs2 into rootfs image.
    -f FILE             Pack cit200.image into firmware image. 
                            cit200.image include kernel,logo,rootfs.
    -e FILE             Pack the update kernel image of the usb scanner EM2027.
    -m FILE             Pack the update application image of the usb scanner EM2027.
    -d FILE             Pack the update kernel image of the scanner EM1300.
    -v VERISON          the version of kernel or application.  Default vaule: 0.1
    -n NAME             the name of component in the name of image.
                        the default name of application  is "app".
                        the default name of kernel image  is "kernel".
                        the defautl name of rootfs image is "rootfs".
                        the default name of firmware image is "firmware".
                        the default name of logo image is "logo".
                        the default name of em2027 kernel image is "em2027kernel".
                        the default name of em2027 application image is "em2027app".
    -h                  Show this usage guide.
Note:
    output file format:
    <product>-<component>-<version>.<buildnr>-<md5sum>.image
f.e:
    cit-kernel-0.2-7ec8feff9530018bbeb6ed47292078dd.image
    cit-app-0.2-91900cb5733b29855f9ee61d9578f6ba.image
    cit-rootfs-0.2-85f2e768019421ac13904de3041b4fbe.image
    cit-firmware-0.2-ba9e7e39c8b64953bc4560b64a8e218b.image
    cit-logo-0.1-667419a7e2f8bbd7929cfec4d2ad47a1.image
    cit-em2027kernel-3.05.024-120133fc25763fa3d2ccc1298461ba3a.image
    cit-em2027app-3.01.013-01cbab5177223bb4d4d71d0d6d9a7dae.image
	
example:
	$Program_Name -s ./app-binary -v 0.2
it will create  cit-app-1.1-91900cb5733b29855f9ee61d9578f6ba.image

	$Program_Name -k ./kernel.cit200 -v 0.2
it will create   cit-kernel-0.2-7ec8feff9530018bbeb6ed47292078dd.image

	$Program_Name -l ./nl_logo.bmp -v 0.2
it will create   cit-logo-0.2-667419a7e2f8bbd7929cfec4d2ad47a1.image

	$Program_Name -r ./rootfs.jffs2 -v 0.2
it will create   cit-rootfs-0.2-85f2e768019421ac13904de3041b4fbe.image

	$Program_Name -f ./cit200.image -v 0.2
it will create   cit-firmware-0.2-ba9e7e39c8b64953bc4560b64a8e218b.image

	$Program_Name -e ./em2027_kernel.bin -v 3.05.024
it will create   cit-em2027kernel-3.05.024-120133fc25763fa3d2ccc1298461ba3a.image

	$Program_Name -m ./em2027_app.bin -v 3.01.013
it will create   cit-em2027app-3.01.013-01cbab5177223bb4d4d71d0d6d9a7dae.image

	$Program_Name -d ./em1300_kernel.bin -v 1.13.7
it will create   cit-em1300kernel-1.13.7-0c7653ecdef58f4d18090f13ea809f46.image

EOF
}
modify_name()
{
	if [ ! -f $Pack_path ] ; then
		echo "can't locate file:$Pack_path"
		exit 1
	fi 
	Md5sum=`md5sum $Pack_path | awk '{print $1}'`
	cp -a $Pack_path $Install_path/$Product-$Component-$Version.$BuildVersion-$Md5sum$Filetype
	if [ ! $? -eq 0 ] ; then
		echo "creat $Component image package error"
	else
		chmod 777 $Install_path/$Product-$Component-$Version.$BuildVersion-$Md5sum$Filetype
		echo "creat $Component image package: $Install_path/$Product-$Component-$Version.$BuildVersion-$Md5sum$Filetype successful"
	fi
	exit 0
}
# pack function 
packd()
{
    set -e 
	 if [ $1 != "app" -a $1 != "firmware" ] ; then	 
		 if [ $1 != "firmwareex" ]; then
			 BuildVersion=build.r`svn info $Pack_path | grep "Last Changed Rev:" | awk '{print $NF}'`
			 changes=`svn status $Pack_path | grep ^[!AMD] | wc -l`
			 if [ $changes != 0 ] ; then
				 BuildVersion=${BuildVersion}M
			 fi
		 fi
	fi
    case "$1" in
		"em2027app")
			modify_name
			exit 0
            ;;
		"em2027kernel")
			modify_name
			exit 0
            ;;
		"em1300kernel")
			modify_name
			exit 0
				;;
        "kernel")
            modify_name
			exit 0
            ;;
        "rootfs")
            modify_name
			exit 0
            ;;
        "firmware")
				BuildVersion=build.r`svnversion -c $Now_path | cut -d : -f 2`
            modify_name
			exit 0
            ;;
        "firmwareex")
				BuildVersion=build.r`svnversion -c $Now_path | cut -d : -f 2`
            modify_name
			exit 0
            ;;
        "logo")
            modify_name
			exit 0
            ;;
        "app")
            if [ ! -d $Pack_path ] ; then
                echo "error path: $Pack_path"
                exit 1
            fi
            # step 1: create tar package
            cd $Pack_path
            tar cf $Install_path/app.tar ./* --exclude=.svn

            if [ ! $? -eq 0 ] ; then
                echo "can't creat application tar package"
                exit 1
            fi

            # step 2: change name into app.image
            cd $Install_path
            if [ ! -f $Install_path/app.tar ] ; then
                echo "can't locate:$Install_path/app.tar"
                exit 1
            fi

            Md5sum=`md5sum $Install_path/app.tar | awk '{print $1}'`
				BuildVersion=build.r`svnversion -c $Now_path/../app-binary | cut -d : -f 2`
            cp -a $Install_path/app.tar $Install_path/$Product-$Component-$Version.$BuildVersion-$Md5sum$Filetype
            if [ ! $? -eq 0 ] ; then
                echo "creat application image package error"
            else
                chmod 777 $Install_path/$Product-$Component-$Version.$BuildVersion-$Md5sum$Filetype
                echo "creat application image package: $Install_path/$Product-$Component-$Version.$BuildVersion-$Md5sum$Filetype successful"
            fi
            rm $Install_path/app.tar -f
			exit 0
            ;;
        *)
            echo "nothing to do ..."
            exit 1
            ;;
    esac
}
# main
if [ $# -lt 2 ] ; then
    usage
    exit 1
fi
# TODO Add long command line options
while getopts "k:s:hv:n:r:f:l:e:m:d:g:" opt ; do
    case "$opt" in
        k)
            # kernel image
            Pack_path=$OPTARG
            Component="kernel"
            ;;
        s)  
            # app
            Pack_path=$OPTARG
            Component="app"
            ;;
        n)  
            # name
            Component=$OPTARG
            ;;
        v)  
            # version
            Version=$OPTARG
            ;; 
        r)
            # rootfs
            Pack_path=$OPTARG
            Component="rootfs"
            ;;
        f)
            # firmware
            Pack_path=$OPTARG
            Component="firmware"
            ;;
        g)
            # firmware
            Pack_path=$OPTARG
            Component="firmwareex"
            ;;
        l)
            # logo
            Pack_path=$OPTARG
            Component="logo"
            ;;
		e)
			# em2027 kernel
			Pack_path=$OPTARG
			Component="em2027kernel"
			;;
		m)
			# em2027 applicatioin
			Pack_path=$OPTARG
			Component="em2027app"
			;;
		d)
			# em1300 kernel
			Pack_path=$OPTARG
			Component="em1300kernel"
			;;
        h)
            usage
            exit 0
            ;;
            
        *)
            usage
            exit 0
            ;;
    esac
done
packd $Component
