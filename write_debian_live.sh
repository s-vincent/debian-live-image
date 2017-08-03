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
HOME_SIZE="+$2"
ERASE="$3"
ISO_NAME="live-image-amd64.hybrid.iso"

if [ $(id -u) -ne 0 ]
then
  echo "Script has to be run as root or sudo"
  exit 1
fi

if [ -z "${USB_DRIVE}" ]
then
  echo "Usage: $0 device [size] [erase]"
  echo "Example: $0 /dev/sdz 2G"
  echo "size parameter is a numeric suffixed by unit (M for MB, G for GB, ...)"
  echo "\tDefault is the maximum size that USB can offer"
  echo "erase parameter is a boolean (true/false) that will, if true, write \
    random data to USB drive before writing image"
  echo "\tDefault is false"
  exit 1
fi

if [ ! -b "${USB_DRIVE}" ]
then
  echo "USB drive ${USB_DRIVE} does not exist!"
  echo "Abort script"
  exit 1
fi

if [ "${HOME_SIZE}" = "+" ]
then
  HOME_SIZE=""
fi

if [ -z "${HOME_SIZE##*.*}" ]
then
  echo "Size must not contains dot";
  echo "To specify dotted size (i.e. 1.5G), use other unit (i.e. 1500M)"
  echo "Abort script"
  exit 1
fi

# summary of information
echo "Write image process"
echo "Device: ${USB_DRIVE}"
echo -n "Write random data to device before: "
if [ "x${ERASE}" = "xtrue" ]
then
  echo "true"
else
  echo "false"
fi
echo -n "Encrypted partition size: "
if [ -z "${HOME_SIZE}" ]
then
  echo "max"
else
  echo "${HOME_SIZE}"
fi

# umount all existing mounting points of the device
umount ${USB_DRIVE}* || true

# populate it with random data (optionally)
if [ "x${ERASE}" = "xtrue" ]
then
  echo "Write random data to USB drive..."
  dd if=/dev/urandom of="${USB_DRIVE}"
fi

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

