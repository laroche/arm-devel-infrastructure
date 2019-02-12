#!/bin/bash
#
# https://www.op-tee.org/
# https://github.com/OP-TEE
#

# option for repo sync, number of parallel downloads
SYNCOPT="-j 6"

# option for building with make, number of parallel compiles
MAKEOPT="-j 8"

# arm32 build of op-tee with qemu:
if true ; then
  if ! test -d optee-qemu ; then
    mkdir optee-qemu
    pushd optee-qemu
    repo init -u https://github.com/OP-TEE/manifest.git -m default.xml -b master # --reference /home/flaroche/data/repo-mirror/optee-qemu
    popd
  fi
  pushd optee-qemu
  repo sync $SYNCOPT
  make -C build toolchains $MAKEOPT
  make -C build $MAKEOPT
  #make -C build run # login as "test" and run "xtest"
  popd
fi

# arm64 build of op-tee with qemu:
if true ; then
  if ! test -d optee-qemu_v8 ; then
    mkdir optee-qemu_v8
    pushd optee-qemu_v8
    repo init -u https://github.com/OP-TEE/manifest.git -m qemu_v8.xml -b master # --reference /home/flaroche/data/repo-mirror/optee-qemu_v8
    popd
  fi
  pushd optee-qemu_v8
  repo sync $SYNCOPT
  make -C build toolchains $MAKEOPT
  make -C build $MAKEOPT
  #make -C build run # login as "test" and run "xtest"
  popd
fi

# RPi3 build of op-tee with qemu:
if false ; then
  if ! test -d optee-rpi3 ; then
    mkdir optee-rpi3
    pushd optee-rpi3
    repo init -u https://github.com/OP-TEE/manifest.git -m rpi3.xml -b master # --reference /home/flaroche/data/repo-mirror/optee-rpi3
    popd
  fi
  pushd optee-rpi3
  repo sync $SYNCOPT
  make -C build toolchains $MAKEOPT
  make -C build $MAKEOPT
  # make img-help
  # make flash
  popd
fi
