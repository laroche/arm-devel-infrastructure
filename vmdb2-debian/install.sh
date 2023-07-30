#!/bin/bash
#
# Download a generic Debian Linux image and start it as virtualized KVM image.
#

# release date to use:
RDATE="20230730"
# Select either "stable", "testing" or "unstable":
TYPE="testing"
# Should we package the image up?
ZIP=0
EFI=0
if test $EFI = 0 ; then
  IMG=debian-amd64.img
else
  IMG=debian-amd64-efi.img
fi

# This is the name of the new system as well as the name of the hard disk for it:
if test "X$1" != "X" ; then
  TARGET="$1"
else
  TARGET=debian01
fi
DISK="$TARGET.qcow2"

# Install needed software:
#sudo apt-get -qq -y install virtinst virt-manager

# Download newest release and unpack:
if ! test -f debian-amd64.img ; then
  wget -q https://github.com/laroche/arm-devel-infrastructure/releases/download/v$RDATE/debian-${TYPE}-amd64-$RDATE.zip
  unzip debian-${TYPE}-amd64-$RDATE.zip
  mv debian-${TYPE}-amd64-$RDATE/debian-${TYPE}-amd64-$RDATE.img debian-amd64.img
  rm -fr debian-${TYPE}-amd64-$RDATE
  #rm -f debian-${TYPE}-amd64-$RDATE.zip
fi

if ! test -f "$DISK" ; then
  # Convert the plain/raw image file into qcow2 format:
  qemu-img convert -O qcow2 $IMG "$DISK"
  # Extend the size a lot:
  qemu-img resize "$DISK" +11G
  # Create a snapshot/backup so you can always revert back to this state:
  qemu-img snapshot -c start "$DISK"
  #qemu-img snapshot -l "$DISK"
  # If a locally modified setup.sh and a new kernel exist, copy those into the new image:
  if test -f setup.sh ; then
    #virt-ls -l -a "$DISK" /
    if test $EFI = 0 ; then
      virt-copy-in -a "$DISK" setup.sh /root/
    else
      virt-copy-in -a "$DISK" -m /dev/sda2:/ setup.sh /root/
    fi
  fi
  # If you later on want to use virt-copy and the command does not recognize the
  # correct root partition, you might have to add this param: -m /dev/sda1
  if test -f linux-image-5.2.0-2-amd64-unsigned_5.2.7-1_amd64.deb ; then
    virt-copy-in -a "$DISK" linux-image-5.2.0-2-amd64-unsigned_5.2.7-1_amd64.deb /root/
  fi
  if test $EFI = 0 ; then
    virt-install --os-variant debian12 --name "$TARGET" --memory 8192 --cpu host --vcpus 4 --boot hd --disk "$DISK" --import
  else
    virt-install --os-variant debian12 --name "$TARGET" --memory 8192 --cpu host --vcpus 4 --boot hd,uefi --disk "$DISK" --import
  fi
  #sudo rm -fr /var/tmp/.guestfs-*
fi

if test $EFI = 0 ; then
  OUT=debian-12-desktop-amd64
else
  OUT=debian-12-desktop-amd64-efi
fi
if test $ZIP = 1 && ! test -f $OUT.zip && ! test -d $OUT ; then
  mkdir -p $OUT
  cp setup.sh install.sh $OUT
  qemu-img convert -O raw debian01.qcow2 $OUT/$OUT.img
  zip -r $OUT.zip $OUT
  rm -fr $OUT
fi

# virsh list --all
# virsh start $TARGET
# virt-viewer $TARGET
# virsh stop $TARGET
# virsh destroy $TARGET
# virsh undefine --nvram $TARGET
# rm -f $TARGET.qcow2

# qemu-img convert -O raw debian01.qcow2 debian01.img
