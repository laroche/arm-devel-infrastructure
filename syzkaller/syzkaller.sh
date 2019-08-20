#!/bin/bash
#
# Build buildroot and syzkaller for armv7 and arm64.
#
# Call this script with param "64" to start the arm64 client.
#

# Build requirements. lynx as browser for non-GUI installs:
sudo apt install golang lynx

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
    ./bin/syz-manager -debug -config=aarch64.cfg
  popd
else
  export GOPATH=`pwd`/gopath
  pushd gopath/src/github.com/google/syzkaller
    ./bin/syz-manager -debug -config=arm.cfg
  popd
fi

