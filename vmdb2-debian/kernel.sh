#!/bin/bash
#
# Recompile a debian kernel. On arm apply the raspberry-pi kernel
# patches to the debian kernel.
#

# Build requirements:
sudo apt install build-essential fakeroot rsync git
sudo apt build-dep linux

# Extract the raspberry-pi patches into a subdirectory:
if ! test -d rpi-patches-4.19.58 ; then
  git clone -b rpi-4.19.y https://github.com/raspberrypi/linux/ rpi-linux
  cd rpi-linux
  git format-patch -o ../rpi-patches-4.19.58 7a6bfa08b938d33ba0a2b80d4f717d4f0dbf9170
  cd ..
fi

git clone --single-branch --depth 1 -b sid https://salsa.debian.org/kernel-team/linux.git
test -f orig/linux_4.19.37.orig.tar.xz || wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.19.37.tar.xz
cd linux
test -f ../orig/linux_4.19.37.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py ../linux-4.19.37.tar.xz
# Just to safe disk space and have a faster compile:
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
if test "X$HOSTTYPE" != "Xx86_64" ; then
  pushd debian/patches
    mkdir bugfix/rpi
    cp ../../../rpi-patches-4.19.49/*.patch bugfix/rpi/
    rm -f bugfix/rpi/0506-Bluetooth-Check-key-sizes-only-when-Secure-Simple-Pa.patch
    ls bugfix/rpi/*.patch >> series
  popd
fi
debian/rules orig
debian/rules debian/control
PAR="$(grep -c ^processor /proc/cpuinfo)"
#PAR=10
DEB_BUILD_OPTIONS="parallel=$PAR" XZ_DEFAULTS="-T 0" fakeroot debian/rules binary-arch 2>&1 | tee LOG
cd ..

