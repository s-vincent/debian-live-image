#!/bin/sh
## debian-live-image - Scripts to build custom Debian USB live image.
## Copyright (c) 2017, Sebastien Vincent
##
## Distributed under the terms of the BSD 3-clause License.
## See the LICENSE file for details.

USB_DRIVE=$1
ARGS=""

if [ $(id -u) -ne 0 ]
then
  echo "Script has to be run as root or sudo"
  exit 1
fi

if [ -z "${USB_DRIVE}" ]
then
  echo "Usage: $0 device [uefi]"
  echo "Example: $0 /dev/sdz"
  exit 1
fi

if [ "x$2" = "xuefi" ]
then
  ARGS="--bios /usr/share/ovmf/OVMF.fd"
fi

kvm -usbdevice disk:${USB_DRIVE}2 -m 2G -k fr ${USB_DRIVE} ${ARGS}

