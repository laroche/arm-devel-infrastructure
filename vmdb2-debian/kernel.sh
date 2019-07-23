#!/bin/bash
#
# Recompile a debian kernel. On arm apply the raspberry-pi kernel
# patches to the debian kernel.
#

# Build requirements:
sudo apt -q -y install build-essential fakeroot rsync git
sudo apt -q -y build-dep linux

KVER=4.19.37

# Should we apply the raspberry-pi kernel patches?
RPIPATCHES=0
if test "X$HOSTTYPE" != "Xx86_64" ; then
  RPIPATCHES=1
  #RVER=$KVER
  RVER=4.19.58
fi

if test "$RPIPATCHES" = 1 -a ! -d rpi-patches-$RVER ; then
  # Extract the raspberry-pi patches into a subdirectory:
  git clone -b rpi-4.19.y https://github.com/raspberrypi/linux/ rpi-linux
  cd rpi-linux
  git format-patch -o ../rpi-patches-$RVER 7a6bfa08b938d33ba0a2b80d4f717d4f0dbf9170
  cd ..
  #rm -fr rpi-linux
fi

if ! test -d linux ; then
  git clone --single-branch --depth 1 -b sid https://salsa.debian.org/kernel-team/linux.git
fi
#exit 0
test -f orig/linux_$KVER.orig.tar.xz || wget -q https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$KVER.tar.xz
cd linux
test -f ../orig/linux_$KVER.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py ../linux-$KVER.tar.xz
# Just to safe disk space and have a faster compile:
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
if test "$RPIPATCHES" = 1 ; then
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

