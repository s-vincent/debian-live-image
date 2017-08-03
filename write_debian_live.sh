#!/bin/sh
## debian-live-image - Scripts to build custom Debian USB live image.
## Copyright (c) 2017, Sebastien Vincent
##
## Distributed under the terms of the BSD 3-clause License.
## See the LICENSE file for details.

set -e

# USB drive to write to, DO NOT FORGET to change it according to your settings!
USB_DRIVE="$1"
# size of the persistent partition (prefixed with +), use empty string to extend
# partition to the end
HOME_SIZE="+10G"
ISO_NAME="live-image-amd64.hybrid.iso"

if [ $(id -u) -ne 0 ]
then
  echo "Script has to be run as root or sudo"
  exit 1
fi

if [ -z "${USB_DRIVE}" ]
then
  echo "Usage: $0 device"                                   
  echo "Example: $0 /dev/sdz"
  exit 1
fi

# umount all existing mounting points of the device
umount ${USB_DRIVE}* || true

# populate it with random data (optionally)
# dd if=/dev/urandom of="${USB_DRIVE}"

# burn it to the USB drive
echo "Burn the image to USB drive..."
dd if="${ISO_NAME}" of="${USB_DRIVE}" bs=4M

# create the home partition (the encrypted ones)
echo "Creates home partition..."
fdisk "${USB_DRIVE}" <<EOF
n
p
3

${HOME_SIZE}
p
w
EOF

# encryption
echo "Encrypt the partition..."
cryptsetup --verbose --verify-passphrase luksFormat "${USB_DRIVE}3"
cryptsetup luksOpen "${USB_DRIVE}3" lb_usb_drive

# create a filesystem in it 
echo "Creates filesystem..."
mkfs.ext4 -L persistence /dev/mapper/lb_usb_drive
mkdir -p /tmp/lb_usb_drive
mount /dev/mapper/lb_usb_drive /tmp/lb_usb_drive

# adds the persistence.conf for... persistence!
echo "Adds persistence.conf file..."
echo "/ union" > /tmp/live-image-amd64-persistence.conf
mv /tmp/live-image-amd64-persistence.conf /tmp/lb_usb_drive/persistence.conf
rm -f /tmp/live-image-amd64-persistence.conf

# close the filesystem and partition
echo "Closes encrypted partition..."
umount /dev/mapper/lb_usb_drive
cryptsetup luksClose /dev/mapper/lb_usb_drive

rm -rf /tmp/lb_usb_drive

echo "Finished"

