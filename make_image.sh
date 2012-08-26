#!/bin/bash

VERSION=1.3

# Device to install rescue system on 
DEST=/dev/sdb
# First partition on target device
P1_DEST=/dev/sdb1

ROOT=/tmp/sysconfig

SDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IMAGES=$SDIR/../output/images

echo "This script will completely erase $DEST."
echo -n "Are you sure you want to continue? [N/y] "

read IS_OK
if [ "$IS_OK" != "Y" -a "$IS_OK" != "y" ]; then
  echo "Exiting..."
  exit
fi

if [ ! -d $ROOT ]; then
  mkdir -p $ROOT
fi


# Make sure buildroot has been compiled
if [ ! -f $IMAGES/rootfs.cpio.bz2 ]; then
  echo "$IMAGES/rootfs.cpio.bz2 is missing.  You must run 'make' in the buildroot directory before running this script."
  exit 1
fi

if [ ! -f  $IMAGES/uInitrd -o $IMAGES/rootfs.cpio.bz2 -nt $IMAGES/uInitrd ]; then
  mkimage -A arm -O linux -T ramdisk -C bzip2 -a 0 -e 0 -n "RescueSystem $VERSION" -d $IMAGES/rootfs.cpio.bz2 $IMAGES/uInitrd
fi


echo "Zeroing $DEST..."
# Zero the first 32M of the card
dd if=/dev/zero of=$DEST bs=1024 count=32768

echo "Making $DEST bootable..."
# Install the uboot images
# The buildroot generated spl doesn't work, so use one precompiled with
# make CROSS_COMPILE=arm-linux-gnueabi- sun4i
dd if=$SDIR/sysconfig/sun4i-spl.bin of=$DEST bs=1024 seek=8
dd if=$IMAGES/u-boot.bin of=$DEST bs=1024 seek=32

echo "Partitioning $DEST..."
# Create partition table and sysconfig partition
cat <<EOF | fdisk $DEST
u
n
p
1
2048
63489
t
b
w
EOF

echo "Populating $P1_DEST"
mkfs.vfat $P1_DEST
echo mount $P1_DEST $ROOT
mount $P1_DEST $ROOT

cp -r $SDIR/sysconfig/skeleton/* $ROOT
cp $IMAGES/uInitrd $IMAGES/uImage $ROOT/rescue
$SDIR/../output/build/uboot-sun4i/tools/mkimage -A arm -O u-boot -T script -C none -n "boot" -d $ROOT/boot.cmd $ROOT/boot.scr

wget https://raw.github.com/doozan/a10-rescue-scripts/master/init-extract-system-bin.sh -O $ROOT/rescue/init-extract-system-bin.sh
wget https://raw.github.com/doozan/a10-rescue-scripts/master/init-modules.sh -O            $ROOT/rescue/init-modules.sh
wget https://raw.github.com/doozan/a10-rescue-scripts/master/init-display.sh -O            $ROOT/rescue/init-display.sh
wget https://raw.github.com/doozan/a10-rescue-scripts/master/autorun-deviceinfo.sh -O      $ROOT/rescue/autorun-deviceinfo.sh

umount $ROOT

dd if=$DEST of=a10_base-$VERSION.img bs=1024 count=32768
zip a10_base-$VERSION.zip a10_base-$VERSION.img

