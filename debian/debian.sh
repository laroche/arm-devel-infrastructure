#!/bin/bash
#
# Copyright (c) 2018-2019, Florian La Roche
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Install Debian for ARM or ARM64, either the stable or testing releases
# together with the emulator Qemu.
#
# Requirements for this script on Debian/Ubuntu hosts:
# sudo apt install qemu-system-arm qemu-efi libarchive-tools xorriso libguestfs-tools
#
# TODO:
# - change cdrom grub entry to immediately start an installation for arm64
# - optionally add serial interface/output during installation
# - look at different EFI versions, use current upstream release
# - add more config for ssh-server, sudo, ntp
# - maybe remove "quiet" kernel/bootup option
# - debian kernel git repo: git clone https://salsa.debian.org/kernel-team/linux.git
# - optionally add the syzkaller and ltp tests
# - try to get rid of sudo to extract the kernel/initrd, extract from deb files?
#

# Select "32" or "64" bit ARM:
if test "X$1" != X ; then
  ARM="$1"
else
  ARM=64
fi

# Select Debian "stable" or "testing":
if test "X$2" != X ; then
  DEBIAN="$2"
else
  DEBIAN=testing
fi

# Select DVD or netinst CD (smaller images) installs:
ISO=cd

# Network port for the current system that gets forwarded to the
# guest system port 22 (sshd server). Empty string to disable this.
if test "X$3" != X ; then
  PORT="$3"
else
  PORT="2222"
fi
# If set to 1, we will only listen on 127.0.0.1, so ssh connections are
# not possible from remote but only from the local host.
PORTSECURE=1

# This script changes quit a few files in this directory, so please make
# sure you have looked through this file and execute it within a new directory.
echo "Please check this script and remove the 'exit 1' to really be able to use it."
exit 1

# Name of the harddisk file we install Debian on:
hd=debian.img.$ARM.$DEBIAN

# Extract the ISO image into this subdirectory:
iso=$hd.iso

# Database of all URLs to the different Debian releases:
if test $DEBIAN = testing ; then
  if test $ARM = 64 ; then
    img=debian-testing-arm64-netinst.iso
    url=http://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/arm64/iso-cd/$img
    label="Debian testing arm64 n"
  else
    img=debian-testing-armhf-netinst.iso
    url=http://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/armhf/iso-cd/$img
    label="Debian testing armhf n"
  fi
else
  VERSION="9.7.0"
  if test $ARM = 64 ; then
    if test $ISO = cd ; then
      img=debian-$VERSION-arm64-netinst.iso
      #img=debian-$VERSION-arm64-xfce-CD-1.iso
      url=https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/$img
      label="Debian $VERSION arm64 n"
      #label="Debian $VERSION arm64 1"
    else
      img=debian-$VERSION-arm64-DVD-1.iso
      url=https://cdimage.debian.org/debian-cd/current/arm64/iso-dvd/$img
      label="Debian $VERSION arm64 1"
    fi
  else
    if test $ISO = cd ; then
      img=debian-$VERSION-armhf-netinst.iso
      #img=debian-$VERSION-armhf-xfce-CD-1.iso
      url=https://cdimage.debian.org/debian-cd/current/armhf/iso-cd/$img
      label="Debian $VERSION armhf n"
      #label="Debian $VERSION armhf 1"
    else
      img=debian-$VERSION-armhf-DVD-1.iso
      url=https://cdimage.debian.org/debian-cd/current/armhf/iso-dvd/$img
      label="Debian $VERSION armhf 1"
    fi
  fi
fi

# To build a current version of qemu:
# - Download source from https://www.qemu.org/download/#source
# - tar xJf qemu-*.tar.xz; cd qemu-*
# - ./configure --prefix=/opt/qemu; make; sudo make install

# Select qemu version:
if test $ARM = 64 ; then
  qemu=/opt/qemu/bin/qemu-system-aarch64
  if ! test -x $qemu ; then
    qemu=qemu-system-aarch64
  fi
else
  qemu=/opt/qemu/bin/qemu-system-arm
  if ! test -x $qemu ; then
    qemu=qemu-system-arm
  fi
fi

# Select EFI ROM for ARM64:
if test $ARM = 64 ; then
  if ! test -f QEMU_EFI.img ; then
    wget http://snapshots.linaro.org/components/kernel/leg-virt-tianocore-edk2-upstream/latest/QEMU-AARCH64/RELEASE_GCC5/QEMU_EFI.img.gz
    gunzip QEMU_EFI.img.gz
    #cp /usr/share/qemu-efi/QEMU_EFI.fd QEMU_EFI.img
  fi
  # EFI Writable/Store:
  if ! test -f $hd.varstore ; then
    qemu-img create -f qcow2 $hd.varstore 64M
  fi
fi

CDROM=""
if test $ARM = 32 ; then
  APPEND="root=/dev/vda2" # quiet
  if test $DEBIAN = testing ; then
    KERNEL=vmlinuz-4.19.0-2-armmp-lpae
    INITRD=initrd.img-4.19.0-2-armmp-lpae
  else
    KERNEL=vmlinuz-4.9.0-8-armmp-lpae
    INITRD=initrd.img-4.9.0-8-armmp-lpae
  fi
fi
NEWINSTALL=0
if ! test -f $hd ; then
  NEWINSTALL=1
  # Create new disk for the client and add the install iso:
  qemu-img create -f qcow2 $hd 128G
  if test $ARM = 64 ; then
    CDROM="-drive if=virtio,format=raw,file=$img.preseed"
  else
    CDROM="-drive if=none,file=$img.preseed,format=raw,id=hd1 -device virtio-blk-device,drive=hd1"
    # "auto" is the same as "auto=true priority=critical"
    APPEND="auto locale=en_US country=US language=en keymap=us file=/preseed.cfg"
    KERNEL=$iso/install/netboot/vmlinuz
    INITRD=$iso/install/netboot/initrd.gz
  fi

  # Download the installer image:
  if ! test -f $img ; then
    wget $url
  fi

  # Re-create the installer image to include preseed information:
  if ! test -f $img.preseed ; then
    mkdir $iso
    bsdtar -C $iso -xf $img
    #xorriso -osirrox on -indev $img -extract / $iso
    #7z x -o$iso $img
    if test $ARM = 64 ; then
      chmod +w -R $iso/install.a64/ $iso/boot/grub/ $iso/md5sum.txt
    else
      chmod +w -R $iso/install/ $iso/md5sum.txt
    fi
    if test $ARM = 64 ; then
      #gunzip $iso/install.a64/initrd.gz
      #echo preseed.cfg | cpio -H newc -o -A --owner=0:0 -F $iso/install.a64/initrd
      #gzip -9 $iso/install.a64/initrd
      cp preseed64.cfg $iso/preseed.cfg
      # cdrom-detect\/load_media=false
      # DEBCONF_DEBUG=5
      # debconf-get-selections --installer > preseed.cfg
      # debconf-get-selections >> preseed.cfg
      sed -i -e 's/vmlinuz \? ---/vmlinuz auto locale=en_US country=US language=en keymap=us cdrom-detect\/manual_config=true cdrom-detect\/cdrom_module=none cdrom-detect\/cdrom_device=\/dev\/vdb file=\/cdrom\/preseed.cfg ---/g' \
	$iso/boot/grub/grub.cfg
    else
      # Append the preseed.cfg file into the compressed cpio archive:
      gunzip $iso/install/netboot/initrd.gz
      echo preseed.cfg | cpio -H newc -o -A --owner=0:0 -F $iso/install/netboot/initrd
      gzip -9 $iso/install/netboot/initrd
    fi

    if test $ARM = 64 ; then
      if true ; then
        imgefi=$iso/boot/grub/efi.img
      else
        # https://wiki.debian.org/RepackBootableISO#arm64_release_9.4.0
        start_block=$(/sbin/fdisk -l "$img" | fgrep "$img"2 | awk '{print $2}')
        block_count=$(/sbin/fdisk -l "$img" | fgrep "$img"2 | awk '{print $4}')
        if test "$start_block" -gt 0 -a "$block_count" -gt 0 2>/dev/null ; then
          imgefi=efi.img
          dd if="$img" bs=512 skip="$start_block" count="$block_count" of=$imgefi
        else
          echo "Cannot read plausible start block and block count from fdisk" >&2
          exit 1
        fi
      fi
    fi

    pushd $iso
      md5sum `find -follow -type f 2>/dev/null` > md5sum.txt
    popd
    if test $ARM = 64 ; then
      chmod -w -R $iso/install.a64/ $iso/boot/grub/ $iso/md5sum.txt
    else
      chmod -w -R $iso/install/ $iso/md5sum.txt
    fi
    if test $ARM = 64 ; then
      xorriso -as mkisofs \
        -r -checksum_algorithm_iso md5,sha1,sha256,sha512 -V "$label" \
        -o "$img.preseed" \
        -J -joliet-long -cache-inodes \
        -e boot/grub/efi.img \
        -no-emul-boot \
        -append_partition 2 0xef $imgefi \
        -partition_cyl_align all \
        $iso
    else
      xorriso -as mkisofs \
        -r -checksum_algorithm_iso md5,sha1,sha256,sha512 -V "$label" \
        -o "$img.preseed" \
        -J -joliet-long -cache-inodes \
        $iso
    fi
  fi

fi

if test "X$PORT" != X ; then
  if test $PORTSECURE = 1 ; then
    PORT=",hostfwd=tcp:127.0.0.1:${PORT}-:22"
  else
    PORT=",hostfwd=tcp::${PORT}-:22"
  fi
fi

# Invoke the guest system either for installation or to just start an existing system:
# Change from *-device to  *-pci once all kernels support this.
if test $ARM = 64 ; then
  # -bios QEMU_EFI.fd
  $qemu \
    -M virt -cpu cortex-a53 -smp 4 -m 1024 -nographic \
    -drive if=pflash,format=raw,file=QEMU_EFI.img,readonly=on \
    -drive if=pflash,file=$hd.varstore \
    -drive if=virtio,file=$hd \
    -netdev user,id=net0$PORT \
    -device virtio-net-device,netdev=net0 \
    $CDROM
else
  # -M vexpress-a9 -cpu cortex-a9 -dtb $iso/install/device-tree/vexpress-v2p-ca9.dtb
  # -append "root=/dev/mmcblk0p1" -sd $hd
  $qemu \
    -M virt \
    -kernel $KERNEL -initrd $INITRD -append "$APPEND" \
    -smp 4 -m 1024 -nographic \
    $CDROM \
    -drive if=none,file=$hd,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -netdev user,id=net0$PORT \
    -device virtio-net-device,netdev=net0
  if test $NEWINSTALL = 1 ; then
    sudo virt-ls -a $hd /boot/
    if test $DEBIAN = testing ; then
      echo sudo virt-copy-out -a $hd /boot/vmlinuz-4.19.0-2-armmp-lpae /boot/initrd.img-4.19.0-2-armmp-lpae .
      sudo virt-copy-out -a $hd /boot/vmlinuz-4.19.0-2-armmp-lpae /boot/initrd.img-4.19.0-2-armmp-lpae .
    else
      echo sudo virt-copy-out -a $hd /boot/vmlinuz-4.9.0-8-armmp-lpae /boot/initrd.img-4.9.0-8-armmp-lpae .
      sudo virt-copy-out -a $hd /boot/vmlinuz-4.9.0-8-armmp-lpae /boot/initrd.img-4.9.0-8-armmp-lpae .
    fi
  fi
fi
if test $NEWINSTALL = 1 ; then
  chmod +w -R $iso
  rm -fr $iso $img.preseed efi.img
  qemu-img convert -O qcow2 $hd $hd.new && mv $hd.new $hd
  qemu-img snapshot -c install $hd
fi
