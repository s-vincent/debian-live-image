# debian-live-image

Scripts to build a custom Debian USB live image with persistent and encrypted
/home.

## Pre-requisites

OS tested:
GNU/Linux Debian Stretch and testing.

The following packages need to be installed: live-build ovmf qemu-kvm

## Usage

Edit packages.list and adds the packages you want.

Build the ISO:

`sudo ./build_debian_live.sh`

Write to an USB key:

`sudo ./write_debian_live.sh /dev/your_device`

WARNING (1): /dev/your_device should be the device not the partition.
Example: not /dev/sdz1 but /dev/sdz.

WARNING (2): Please CAREFULLY choose the USB device (/dev/your_device) because
everything stored will be erased (partitions, data, ...) after the previous
command.

To test your image with QEMU/KVM:

`sudo ./kvm_debian_live.sh /dev/your_device`

To clean the repository (everything but the cache):

`sudo ./clean_debian_live.sh`

To remove cache:

`sudo rm -rf ./cache`

## Limitations

Currently the produced image is built from Debian stable and will be localized
in french.

To build from Debian sid:
 * edit build\_debian\_live.sh and replace "--distribution stretch" by 
 "--distribution sid".

Modify the following to have a different language support:
 * edit build\_debian\_live.sh and replace "fr_FR.UTF-8" occurences by your
 desired locales (type `locale` to have your current locale on your machine);
 * edit 0051-initramfs-keymap.chroot and replace "fr" by your desired XKB
 layout.

## Links

 * https://github.com/debian-live
 * http://forums.debian.net/viewtopic.php?t=95342&start=15 (maybe outdated)
 * https://lescahiersdudebutant.fr/tools/HOWTO-livebuild-stretch.pdf (in
 french)
