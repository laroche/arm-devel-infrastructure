#!/bin/bash
#
# Recompile a debian kernel. On arm apply the raspberry-pi kernel
# patches to the debian kernel.
#

# Build requirements:
sudo apt install build-essential fakeroot rsync git
sudo apt build-dep linux

# Extract the raspberry-pi patches into a subdirectory:
if ! test -d rpi-patches-5.2.1 ; then
  git clone -b rpi-5.2.y https://github.com/raspberrypi/linux/ rpi-linux-5
  cd rpi-linux-5
  git format-patch -o ../rpi-patches-5.2.1 527a3db363a3bd7e6ae0a77da809e01847a9931c
  cd ..
fi

git clone --single-branch --depth 1 https://salsa.debian.org/kernel-team/linux.git linux-5
test -f orig/linux_5.2.1.orig.tar.xz || wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.2.1.tar.xz
cd linux-5
test -f ../orig/linux_5.2.1.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py ../linux-5.2.1.tar.xz
# Just to safe disk space and have a faster compile:
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
if test "X$HOSTTYPE" != "Xx86_64" ; then
  pushd debian/patches
    mkdir bugfix/rpi
    cp ../../../rpi-patches-5.2.1/*.patch bugfix/rpi/
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

