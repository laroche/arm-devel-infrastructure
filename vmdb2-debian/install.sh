#!/bin/bash
#
# Download a generic Debian Linux image and start it as virtualized KVM image.
#

# This is the name of the new system as well as the name of the harddisk for it:
if test "X$1" != "X" ; then
  TARGET="$1"
else
  TARGET=debian01
fi
DISK="$TARGET.qcow2"

# Install needed software:
#sudo apt -q -y install virtinst virt-manager

# Download newest release and unpack:
if ! test -f debian-amd64.img ; then
  wget https://github.com/laroche/arm-devel-infrastructure/releases/download/v20190720/debian-stable-amd64-20190720.zip
  unzip debian-stable-amd64-20190720.zip
  mv debian-stable-amd64-20190720/debian-stable-amd64-20190720.img debian-amd64.img
  rm -fr debian-stable-amd64-20190720
fi

if ! test -f "$DISK" ; then
  # Convert the plain/raw image file into qcow2 format:
  qemu-img convert -O qcow2 debian-amd64.img "$DISK"
  # Extend the size a lot:
  qemu-img resize "$DISK" +80G
  # Create a snapshot/backup so you can always revert back to this state:
  qemu-img snapshot -c start "$DISK"
  #qemu-img snapshot -l "$DISK"
  virt-install --name "$TARGET" --memory 4096 --cpu host --vcpus 4 --boot hd --disk "$DISK"
  # --os-variant debiansqueeze
  # --boot hd,uefi
fi
