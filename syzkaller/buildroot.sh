#!/bin/bash

test -d buildroot || {
  git clone https://github.com/buildroot/buildroot.git
  pushd buildroot
  for i in board/qemu/arm-vexpress/linux-fragment.config board/qemu/arm-vexpress/post-build.sh \
	system/skeleton/etc/timezone ; do
    touch $i
    git add $i
  done
  patch -s -p1 < ../buildroot.patch
  popd
}
test -d buildroot && {
  pushd buildroot
  git pull -a --all
  popd
}

# make qemu_arm_vexpress_defconfig
# make
# qemu-system-arm -M vexpress-a9 -cpu cortex-a9 -smp 4 -m 256 -kernel output/images/zImage -dtb output/images/vexpress-v2p-ca9.dtb -drive file=output/images/rootfs.ext2,if=sd,format=raw -append "console=ttyAMA0,115200 rootwait root=/dev/mmcblk0" -net nic,model=lan9118 -net user -nographic # -serial stdio -display none

# make qemu_aarch64_virt_defconfig
# make
# qemu-system-aarch64 -M virt -cpu cortex-a53 -smp 4 -m 768 -kernel output/images/Image -append "rootwait root=/dev/vda console=ttyAMA0" -netdev user,id=eth0 -device virtio-net-device,netdev=eth0 -drive file=output/images/rootfs.ext4,if=none,format=raw,id=hd0 -device virtio-blk-device,drive=hd0 -nographic # -serial stdio -display none

