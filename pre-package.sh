#!/bin/sh

TARGET=$1

rm $TARGET/etc/wpa_supplicant.conf
ln -s /mnt/sysconfig/rescue/wpa_supplicant.conf $TARGET/etc/wpa_supplicant.conf

rm $TARGET/etc/network/interfaces
ln -s /mnt/sysconfig/rescue/interfaces $TARGET/etc/network/interfaces

#mknod $TARGET/dev/mmcblk0   b 179 0
#mknod $TARGET/dev/mmcblk0p1 b 179 1
#mknod $TARGET/dev/mmcblk0p2 b 179 2
#mknod $TARGET/dev/mmcblk0p3 b 179 3
#mknod $TARGET/dev/mmcblk0p4 b 179 4
#mknod $TARGET/dev/mmcblk0p5 b 179 5
#mknod $TARGET/dev/mmcblk0p6 b 179 6
#mknod $TARGET/dev/mmcblk0p7 b 179 7
#mknod $TARGET/dev/mmcblk0p8 b 179 8

cp -r $TARGET/../../custom/fs-overlay/* $TARGET/
