#!/bin/bash 
if [ "$(whoami)" != 'root' ]; then
   echo "You have no permission to run $0 as non-root user."
   exit 1;
fi
Program_Name=$0
Now_path=`pwd`
Pack_name="app"
Pack_version=1.0
Pack_path=
Pack_type="app"
# usage
usage()
{
    cat <<EOF
	
	
Usage:  $Program_Name [OPTIONS]

Packing tool for cit200
Options:
	-k FILE			Pack a kernel_image_file
	-s PATH			Pack the application for cit200. 
	-v VERISON		the version of kernel or application.  Default vaule: 1.0
	-n NAME			the name of kernel or application package.
					the default name of application package is "app".
					the default name of kernel image package is "kernel_image".
	-h			Show this usage guide.

example:
	$Program_Name -s cit-0.4-5-g3559f64 -v 1.1
it will create app_1.1.tar package.
	$Program_Name -k cit200_image -v 1.1
it will creat kernel_image_1.1.tar package.	
	
EOF
}

# pack function 
packd()
{
    set -e 
    case "$1" in
        "kernel")
            if [ ! -f $Pack_path ] ; then
                echo "error file:$Pack_path"
            fi 
            tar cf $Now_path/$Pack_name"_"$Pack_version.tar $Pack_path
            if [ ! $? -eq 0 ] ; then
                echo "creat kernel image tar package error"
            else
                echo "creat kernel image tar package: $Now_path/$Pack_name_$Pack_version.tar successful"
            fi
			exit 0
            ;;
        "app")

            if [ ! -d $Pack_path ] ; then
                echo "error path: $Pack_path"
            fi
            cd $Pack_path
            tar cf $Now_path/$Pack_name"_"$Pack_version.tar ./*

            if [ ! $? -eq 0 ] ; then
                echo "creat application tar package error"
            else
                echo "creat application tar package: $Now_path/$Pack_name"_"$Pack_version.tar successful"
            fi
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
while getopts "k:s:hv:n:" opt ; do
    case "$opt" in
        k)
            Pack_path=$OPTARG
            Pack_name="kernel_image"
            Pack_type="kernel"       
            ;;
        s)  
            Pack_path=$OPTARG
            Pack_type="app"
            ;;
        n)  
            Pack_name=$OPTARG
            ;;
        v)  
            Pack_version=$OPTARG
			
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
packd $Pack_type
