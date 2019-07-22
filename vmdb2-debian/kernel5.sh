#!/bin/bash
#
# Recompile a debian kernel. On arm apply the raspberry-pi kernel
# patches to the debian kernel.
#

# Build requirements:
sudo apt install build-essential fakeroot rsync git
sudo apt build-dep linux

KVER=5.2.1

# Should we apply the raspberry-pi kernel patches?
RPIPATCHES=0
if test "X$HOSTTYPE" != "Xx86_64" ; then
  RPIPATCHES=1
  RVER=$KVER
  #RVER=5.2.1
fi

if test "$RPIPATCHES" = 1 -a ! -d rpi-patches-$RVER ; then
  # Extract the raspberry-pi patches into a subdirectory:
  git clone -b rpi-5.2.y https://github.com/raspberrypi/linux/ rpi-linux-5
  cd rpi-linux-5
  git format-patch -o ../rpi-patches-$RVER 527a3db363a3bd7e6ae0a77da809e01847a9931c
  cd ..
fi

if ! test -d linux-5 ; then
  git clone --single-branch --depth 1 https://salsa.debian.org/kernel-team/linux.git linux-5
fi
#exit 0
test -f orig/linux_$KVER.orig.tar.xz || wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KVER.tar.xz
cd linux-5
test -f ../orig/linux_$KVER.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py ../linux-$KVER.tar.xz
# Just to safe disk space and have a faster compile:
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
if test "$RPIPATCHES" = 1 ; then
  pushd debian/patches
    mkdir bugfix/rpi
    cp ../../../rpi-patches-$RVER/*.patch bugfix/rpi/
    ls bugfix/rpi/*.patch >> series
  popd
  # Current 5.2.y does not compile with CONFIG_RTL8192CU
  sed -i -e 's/CONFIG_RTL8192CU=m/CONFIG_RTL8192CU=n/g' debian/config/config
fi
debian/rules orig
debian/rules debian/control
PAR="$(grep -c ^processor /proc/cpuinfo)"
#PAR=10
DEB_BUILD_OPTIONS="parallel=$PAR" XZ_DEFAULTS="-T 0" fakeroot debian/rules binary-arch 2>&1 | tee LOG
cd ..

