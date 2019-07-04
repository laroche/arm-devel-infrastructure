#!/bin/bash
#
# Download a generic Debian Linux image and start it as virtualized KVM image.
#

TARGET=debian01

DISK=$TARGET.qcow2

# Download newest release and unpack:
if ! test -f debian-amd64.img ; then
  wget https://github.com/laroche/arm-devel-infrastructure/releases/download/v20190628/debian-buster-amd64-core-20190628.zip
  unzip debian-buster-amd64-core-20190628.zip
  mv debian-buster-amd64-core-20190628/debian-buster-amd64-core-20190628.img debian-amd64.img
  rm -fr debian-buster-amd64-core-20190628
fi

if ! test -f $DISK ; then
  qemu-img convert -O qcow2 debian-amd64.img $DISK
  qemu-img resize $DISK +50G
  qemu-img snapshot -c start $DISK
  #qemu-img snapshot -l $DISK
  virt-install --name $TARGET --memory 4096 --cpu host --vcpus 4 --boot hd --disk $DISK
  # --os-variant debiansqueeze
  # --boot hd,uefi
fi
