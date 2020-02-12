#!/bin/bash
#
# Recompile a debian kernel. On arm apply the raspberry-pi kernel
# patches to the debian kernel.
#
# The following params are possible:
# - no param: compile for the current arch a current Debian kernel
# - "armhf": cross-compile a current generic armhf Debian kernel
# - "arm64": cross-compile a current generic arm64 Debian kernel
# - "rpi-armhf": cross-compile a current armhf Debian kernel including all raspberry-pi patches
# - "rpi-arm64": cross-compile a current arm64 Debian kernel including all raspberry-pi patches
#
# https://wiki.debian.org/HowToCrossBuildAnOfficialDebianKernelPackage
#

# Should we apply the raspberry-pi kernel patches?
RPIPATCHES=0
if test "X$HOSTTYPE" != "Xx86_64" ; then
  RPIPATCHES=1
fi

CROSS=0
ARCH=
if test "X$1" = "Xarm64" -o "X$1" = "Xrpi-arm64" ; then
  CROSS=1
  ARCH=arm64
  if test "X$1" = "Xrpi-arm64" ; then
    RPIPATCHES=1
  fi
fi
if test "X$1" = "Xarmhf" -o "X$1" = "Xrpi-armhf" ; then
  CROSS=1
  ARCH=armhf
  if test "X$1" = "Xrpi-armhf" ; then
    RPIPATCHES=1
  fi
fi

# Build requirements:
if true ; then
sudo apt -q -y install build-essential fakeroot rsync git python-debian python3-debian
sudo apt -q -y build-dep linux
if test $CROSS = 1 ; then
  sudo apt -q -y install kernel-wedge quilt ccache flex bison libssl-dev
  sudo apt -q -y install crossbuild-essential-arm64 crossbuild-essential-armhf
  #sudo apt -q -y install g++-9-aarch64-linux-gnu g++-9-arm-linux-gnueabihf
fi
fi

KVER=5.4.19

if test $RPIPATCHES = 1 ; then
  #RVER=$KVER
  RVER=5.4.18
fi

if test "$RPIPATCHES" = 1 -a ! -d rpi-patches-$RVER ; then
  # Extract the raspberry-pi patches into a subdirectory:
  if test ! -d rpi-linux-5 ; then
    git clone -b rpi-5.4.y https://github.com/raspberrypi/linux/ rpi-linux-5
  fi
  cd rpi-linux-5
  git format-patch -o ../rpi-patches-$RVER 58c72057f662cee4ec2aaab9be1abeced884814a
  cd ..
  #rm -fr rpi-linux-5
fi

if ! test -d linux-5 ; then
  git clone --single-branch --depth 1 -b sid https://salsa.debian.org/kernel-team/linux.git linux-5
fi
# Change Debian source to new version:
#sed -i -e '1 s/5.4.14-1/5.4.18-2/' linux-5/debian/changelog
#sed -i -e 's,bugfix/all/i40e-prevent-memory-leak-in-i40e_setup_macvlans.patch,,g' linux-5/debian/patches/series
#sed -i -e 's,workqueue-Convert-for_each_wq-to-use-built-in-list-c.patch,,g' linux-5/debian/patches-rt/series
#exit 0
test -f orig/linux_$KVER.orig.tar.xz || wget -q https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KVER.tar.xz
cd linux-5
test -f ../orig/linux_$KVER.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py ../linux-$KVER.tar.xz
# Just to safe disk space and have a faster compile:
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
if test "$RPIPATCHES" = 1 ; then
  pushd debian/patches
    mkdir bugfix/rpi
    cp ../../../rpi-patches-$RVER/*.patch bugfix/rpi/
    rm -f bugfix/rpi/0351-media-i2c-Add-a-driver-for-the-Infineon-IRS1125-dept.patch
    ls bugfix/rpi/*.patch >> series
  popd
  rm -f debian/abi/5.4.0-?/arm*
fi
rm -fr debian/abi/5.4.0-?

if test $CROSS = 0 ; then

debian/rules orig
debian/rules debian/control
PAR="$(grep -c ^processor /proc/cpuinfo)"
#PAR=10
DEB_BUILD_OPTIONS="parallel=$PAR" XZ_DEFAULTS="-T 0" fakeroot debian/rules binary-arch 2>&1 | tee LOG

else

export $(dpkg-architecture -a$ARCH)
export PATH=/usr/lib/ccache:$PATH
# Build profiles is from: https://salsa.debian.org/kernel-team/linux/blob/master/debian/README.source
export DEB_BUILD_PROFILES="cross nopython nodoc pkg.linux.notools"
# Enable build in parallel
export MAKEFLAGS="-j$(($(nproc)*2))"
# Disable -dbg (debug) package is only possible when distribution="UNRELEASED" in debian/changelog
export DEBIAN_KERNEL_DISABLE_DEBUG=
[ "$(dpkg-parsechangelog --show-field Distribution)" = "UNRELEASED" ] &&
  export DEBIAN_KERNEL_DISABLE_DEBUG=yes

fakeroot make -f debian/rules clean
fakeroot make -f debian/rules orig
fakeroot make -f debian/rules source
fakeroot make -f debian/rules.gen setup_${ARCH}
sed -i 's/binary-arch_arm64:: binary-arch_arm64_none binary-arch_arm64_real/binary-arch_arm64:: binary-arch_arm64_none/' debian/rules.gen
sed -i 's/binary-arch_armhf:: binary-arch_armhf_extra binary-arch_armhf_none binary-arch_armhf_real/binary-arch_armhf:: binary-arch_armhf_extra binary-arch_armhf_none/' debian/rules.gen
fakeroot make -f debian/rules.gen binary-arch_${ARCH}

fi

cd ..

