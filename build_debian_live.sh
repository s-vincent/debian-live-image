#!/bin/sh
## debian-live-image - Scripts to build custom Debian USB live image.
## Copyright (c) 2017-2019, Sebastien Vincent
##
## Distributed under the terms of the BSD 3-clause License.
## See the LICENSE file for details.

set -e

if [ $(id -u) -ne 0 ]
then
  echo "Script has to be run as root or sudo"
  exit 1
fi

# Basic live-build configuration
lb config  \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --distribution buster \
  --linux-flavours amd64 \
  --archive-areas "main contrib non-free" \
  --apt-recommends true \
  --bootappend-live "boot=live config components locale=fr_FR.UTF-8 \
    locales=fr_FR.UTF-8 keyboard-layouts=fr keyb=fr persistence \
    persistent=cryptsetup persistence-encryption=luks"

# Additional packages
cp packages.list config/package-lists/package.list.chroot

# Configure keyboard for kernel boot (to have the right layout for typing LUKS
# passphrase)
cp ./0051-initramfs-keymap.chroot config/hooks/0051-initramfs-keymap.chroot
cp ./0051-initramfs-keymap.chroot config/hooks/normal/
cp ./0051-initramfs-keymap.chroot config/hooks/live/
cp ./0052-cryptsetup-conf-hook.chroot config/hooks/
cp ./0052-cryptsetup-conf-hook.chroot config/hooks/normal/
cp ./0052-cryptsetup-conf-hook.chroot config/hooks/live/

# build the live distribution
lb build

