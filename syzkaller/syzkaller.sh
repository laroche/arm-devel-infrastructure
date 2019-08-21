#!/bin/bash
#
# Build syzkaller together with buildroot for armv7 and arm64.
# Documentation might go to:
# https://github.com/laroche/arm-devel-infrastructure/blob/master/docs/DebianKernel.md#syzkaller
#
# This assumes a Debian unstable distribution, Debian 10 or
# Ubuntu should also work ok.
#
# Without any param, a 32-bit armv7 build is tested, with "64" as
# param an arm64 build is started.
#

# Build requirements. lynx as browser for non-GUI installs:
sudo apt install golang lynx
# make git qemu patch gcc

# Cleanup:
if test "X$1" = Xclean ; then
  rm -fr n dl buildroot gopath
  exit 0
fi

if test "X$1" = X ; then
# Compile buildroot for armv7:
if test ! -d buildroot ; then
  if test ! -d dl -a -d ~/data/dl ; then
    ln -sfn ~/data/dl .
  fi
  git clone --single-branch --depth 1 https://github.com/buildroot/buildroot.git
  pushd buildroot
    patch -s -p1 < ../buildroot.patch
    make qemu_arm_vexpress_defconfig
    make -j 10
  popd
fi
else
# Compile buildroot for aarch64:
if test ! -d n/buildroot ; then
  mkdir -p n
  cp buildroot.patch n
  pushd n
    ln -snf ../dl .
    git clone --single-branch --depth 1 https://github.com/buildroot/buildroot.git
    pushd buildroot
      patch -s -p1 < ../buildroot.patch
      make qemu_aarch64_virt_defconfig
      make -j 10
    popd
  popd
fi
fi

if test "X$1" = X ; then
# Install syzkaller for armv7:
if test ! -d gopath ; then
  mkdir gopath
  export GOPATH=`pwd`/gopath
  go get -u -d github.com/google/syzkaller/...
  pushd gopath/src/github.com/google/syzkaller
    mkdir workdir
    patch -s -p1 < ../../../../../syzkaller.patch
    make TARGETARCH=arm
  popd
fi
else
# Install syzkaller for arm64:
if test ! -d n/gopath ; then
  pushd n
  mkdir gopath
  export GOPATH=`pwd`/gopath
  go get -u -d github.com/google/syzkaller/...
  pushd gopath/src/github.com/google/syzkaller
    mkdir workdir64
    patch -s -p1 < ../../../../../../syzkaller.patch
    make TARGETARCH=arm64
  popd
  popd
fi
fi

# Start syzkaller:
export PATH=/opt/qemu/bin:$PATH
if test "X$1" = X64 ; then
  export GOPATH=`pwd`/n/gopath
  pushd n/gopath/src/github.com/google/syzkaller
    ./bin/syz-manager -config=aarch64.cfg #-debug
  popd
else
  export GOPATH=`pwd`/gopath
  pushd gopath/src/github.com/google/syzkaller
    ./bin/syz-manager -config=arm.cfg #-debug
  popd
fi

