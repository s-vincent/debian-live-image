#!/bin/sh
## debian-live-image - Scripts to build custom Debian USB live image.
## Copyright (c) 2017, Sebastien Vincent
##
## Distributed under the terms of the BSD 3-clause License.
## See the LICENSE file for details.

set -e

if [ $(id -u) -ne 0 ]
then
  echo "Script has to be run as root or sudo"
  exit 1
fi

rm -rf .build config local auto
rm -rf chroot* live-image* binary

