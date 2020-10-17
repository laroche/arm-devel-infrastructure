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

#export LANG=en_US.UTF-8

# Build requirements:
if true ; then
sudo apt-get -qq -y install build-essential fakeroot rsync git python3-debian libcap-dev
sudo apt-get -qq -y build-dep linux g++-10
if test $CROSS = 1 ; then
  sudo apt-get -qq -y install kernel-wedge quilt ccache flex bison libssl-dev
  sudo apt-get -qq -y install crossbuild-essential-arm64 crossbuild-essential-armhf
  sudo apt-get -qq -y install g++-10-aarch64-linux-gnu g++-10-arm-linux-gnueabihf
fi
fi

KVER=5.8.16

if test $RPIPATCHES = 1 ; then
  #RVER=$KVER
  RVER=5.8.15
fi

if test "$RPIPATCHES" = 1 -a ! -d rpi-patches-$RVER ; then
  # Extract the raspberry-pi patches into a subdirectory:
  if test ! -d rpi-linux-5 ; then
    git clone -b rpi-5.8.y https://github.com/raspberrypi/linux/ rpi-linux-5
  else
    pushd rpi-linux-5
    git checkout rpi-5.8.y
    popd
  fi
  cd rpi-linux-5 || exit 1
  git format-patch -o ../rpi-patches-$RVER 665c6ff082e214537beef2e39ec366cddf446d52
  cd ..
  #rm -fr rpi-linux-5
fi

if ! test -d linux-5 ; then
  git clone --single-branch --depth 1 -b sid https://salsa.debian.org/kernel-team/linux.git linux-5
fi
# Change Debian source to new version:
sed -i -e '1 s/5.8.14-1) unstable/5.8.16-1) UNRELEASED/' linux-5/debian/changelog
#sed -i -e 's,^bugfix/all/geneve-add-transport-ports-in-route-lookup-for-genev.patch,,g' linux-5/debian/patches/series
#sed -i -e 's,pci-switchtec-Don-t-use-completion-s-wait-queue.patch,,g' linux-5/debian/patches-rt/series
#exit 0
test -f orig/linux_$KVER.orig.tar.xz || wget -q https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KVER.tar.xz
cd linux-5 || exit 1
test -f ../orig/linux_$KVER.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py ../linux-$KVER.tar.xz
# Just to safe disk space and have a faster compile:
export DEBIAN_KERNEL_DISABLE_DEBUG=yes
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
# Disable RT kernel:
#sed -i -e 's/^enabled: true/enabled: false/g' debian/config/defines
if test "$RPIPATCHES" = 1 ; then
  sed -i -e 's/--fuzz=0//g' debian/rules
  pushd debian/patches
    mkdir bugfix/rpi
    cp ../../../rpi-patches-$RVER/*.patch bugfix/rpi/
    rm -f bugfix/rpi/0710-Bluetooth-A2MP-Fix-not-initializing-all-members.patch \
          bugfix/rpi/0711-Bluetooth-L2CAP-Fix-calling-sk_filter-on-non-socket-.patch \
          bugfix/rpi/0713-Bluetooth-MGMT-Fix-not-checking-if-BT_HS-is-enabled.patch
    ls bugfix/rpi/*.patch >> series
  popd
  rm -f debian/abi/5.8.0-?/arm*
fi
rm -fr debian/abi/5.8.0-?

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

