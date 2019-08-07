#!/bin/bash
#
# Download a generic Debian Linux image and start it as virtualized KVM image.
#

# release date to use
RDATE="20190720"

# This is the name of the new system as well as the name of the hard disk for it:
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
  wget -q https://github.com/laroche/arm-devel-infrastructure/releases/download/v$RDATE/debian-stable-amd64-$RDATE.zip
  unzip debian-stable-amd64-$RDATE.zip
  mv debian-stable-amd64-$RDATE/debian-stable-amd64-$RDATE.img debian-amd64.img
  rm -fr debian-stable-amd64-$RDATE
fi

if ! test -f "$DISK" ; then
  # Convert the plain/raw image file into qcow2 format:
  qemu-img convert -O qcow2 debian-amd64.img "$DISK"
  # Extend the size a lot:
  qemu-img resize "$DISK" +80G
  # Create a snapshot/backup so you can always revert back to this state:
  qemu-img snapshot -c start "$DISK"
  #qemu-img snapshot -l "$DISK"
  # If a locally modified setup.sh and a new kernel exist, copy those into the new image:
  if test -f setup.sh ; then
    #sudo virt-ls -l -a "$DISK" /
    sudo virt-copy-in -a "$DISK" setup.sh /root/
  fi
  # If you later on want to use virt-copy and the command does not recognize the
  # correct root partition, you might have to add this param: -m /dev/sda1
  if test -f linux-image-5.2.0-2-amd64-unsigned_5.2.7-1_amd64.deb ; then
    sudo virt-copy-in -a "$DISK" linux-image-5.2.0-2-amd64-unsigned_5.2.7-1_amd64.deb /root/
  fi
  virt-install --name "$TARGET" --memory 4096 --cpu host --vcpus 4 --boot hd --disk "$DISK"
  # --os-variant debiansqueeze
  # --boot hd,uefi
fi
