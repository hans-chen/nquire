#!/bin/sh 
mount -t tmpfs tmpfs /new_rootfs
mount --bind /new_rootfs /new_rootfs

mkdir -p /new_rootfs/bin
cd /new_rootfs
mkdir -p bin dev home mnt proc sys tmp home/ftp old_rootfs lib appfs
#cp -a /lib/libnss_files* /new_rootfs/lib/
busybox --install -s /new_rootfs/bin/
cp -avf /bin/busybox /new_rootfs/bin/
cp -avf /etc.upgrade /new_rootfs/etc

# stop app
/cit200/cit stop
/sbin/cit_keepalive 
killall vsftpd

mount -o move /proc /new_rootfs/proc/

mkfifo /tmp/cmdfifo
fbsplash -s  /etc.upgrade/upgrade/logo.ppm.gz -f /tmp/cmdfifo -i /etc.upgrade/upgrade/fbsplash.cfg -m  /etc.upgrade/upgrade/font.psf.gz &
echo "00" > /tmp/cmdfifo
echo "write:   " > /tmp/cmdfifo

# switch 
pivot_root /new_rootfs /new_rootfs/old_rootfs

hostname NEWLAND_Nquire
mount -o move /old_rootfs/sys /sys
mount -o move /old_rootfs/tmp /tmp 
mount -o move /old_rootfs/home/ftp /home/ftp

cp -avf /old_rootfs/dev/* /dev/

mount -o move /old_rootfs/dev/pts /dev/pts
umount -r /old_rootfs/dev/
umount -r /old_rootfs/mnt/
umount -r /old_rootfs/new_rootfs/
umount -r /home/ftp/img/default
umount -r /home/ftp/log
umount -r /home/ftp/img
umount -r /old_rootfs/appfs 
umount -r /old_rootfs/

cit_upgrade -A
if [[ "$?" == "0" ]] ; then
echo "write:Rebooting...." > /tmp/cmdfifo
reboot
else
echo "write:upgrade fail" > /tmp/cmdfifo
fi
