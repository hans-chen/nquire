#!/bin/sh
Program_Name=$0
Now_path=`pwd`
Pack_name="app"
Pack_version=1.0
Unpack_path=
Pack_file_path=
Pack_type="app"
usage()
{
    cat <<EOF
	
	
Usage:  $Program_Name [OPTIONS]

Unpacking tool for cit200
Options:
	-k FILE			Unpack kernel_image_file.tar package.
	-s FILE			Unpack the application for cit200 package.
	-h			Show this usage guide.

example:
	$Program_Name -s app_1.0.tar
	$Program_Name -k cit200_image_1.0.tar
	
EOF
}
# main
if [ $# -lt 2 ] ; then
    usage
    exit 1
fi
# TODO Add long command line options.
while getopts "k:s:h" opt ; do
    set -e 
    case "$opt" in
        k)
			Pack_file_path=$OPTARG
			Unpack_path="/tmp"
            ;;
        s)
			Pack_file_path=$OPTARG
			Unpack_path="/cit200"
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
set -e
if [ ! -f $Pack_file_path ] ; then
    echo -en "can't open\t" $Package_path/$Package_name.tar "\n"
    exit 1 
fi
if [ ! -d $Unpack_path ] ; then
   echo -en "can't locate \t" $Unpack_path  "\n"
   exit 1
fi 
tar -xf $Pack_file_path -C $Unpack_path
if [ $? -eq 0 ] ; then
    echo -en "unpack successful\n"
    exit 1
else
    echo -en "unpack fail\n"
    exit 0
fi