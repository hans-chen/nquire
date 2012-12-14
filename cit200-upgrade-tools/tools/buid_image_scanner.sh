#!/bin/bash  
[ $# -lt 4 ] && echo "Usage: build_image_scanner.sh  IMAGE_PATH IMAGE_TYPE IMAGE_VERSION TARGET_IMAGE"
IMAGE_PATH=$1
IMAGE_TYPE=$2
IMAGE_VERSION=$3
TARGET_IMAGE=$4
[ -f $IMAGE_PATH ] && SIZE_IMAGE=`du -b $IMAGE_PATH | awk '{print $1}'`
[ -f $TARGET_IMAGE ] && SIZE_FIRMWARE=`du -b $TARGET_IMAGE | awk '{print $1}'`
#echo "SIZE_IMAGE:" $SIZE_IMAGE
#echo "SIZE_FIRMWARE:" $SIZE_FIRMWARE
echo "TYPE:$IMAGE_TYPE;VERSION:$IMAGE_VERSION;SIZE:$SIZE_IMAGE;" >> $TARGET_IMAGE
dd if=$IMAGE_PATH of=$TARGET_IMAGE bs=1 seek=$(($SIZE_FIRMWARE+128))