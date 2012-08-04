This partition is reserved for system/boot configs plus a rescue system.

/system.bin - device-specific hardware configuration, extracted from Android partition
boot.scr = compiled uboot environment
boot.cmd = source code for uboot environment, this file can be compiled
with the following command:
mkimage -A arm -O u-boot -T script -C none -n "boot" -d boot.cmd boot.scr


/rescue
======
The images in /rescue will be loaded if no system is found on the mmc0p2 partition.
The rescue system should have just enough tools to allow you to ssh to your device
and repair or install an operating system.

You can force booting to the rescue system by creating a file named 'force_rescue.txt'
in the /rescue directory.

You can also configure the wireless network settings for the rescue system by editing
the network_interfaces file.  If you're editing this file on Windows, be sure to use
an editor that will preserve the UNIX line endings (Notepad2 is a safe choice)

The rescue system includes a precompiled fexc binary.  Full source is available
at http://github.com/amery/sunxi-tools
