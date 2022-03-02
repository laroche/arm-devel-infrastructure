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
sudo apt-get -qq -y install build-essential fakeroot rsync git python3-debian libcap-dev g++-10
sudo apt-get -qq -y build-dep linux
if test $CROSS = 1 ; then
  sudo apt-get -qq -y install kernel-wedge quilt ccache flex bison libssl-dev
  sudo apt-get -qq -y install crossbuild-essential-arm64 crossbuild-essential-armhf
  sudo apt-get -qq -y install g++-10-aarch64-linux-gnu g++-10-arm-linux-gnueabihf
fi
fi

KVER=5.10.103

if test $RPIPATCHES = 1 ; then
  #RVER=$KVER
  RVER=5.10.95
fi

if test "$RPIPATCHES" = 1 -a ! -d rpi-patches-$RVER ; then
  # Extract the raspberry-pi patches into a subdirectory:
  if test ! -d rpi-linux-5 ; then
    git clone -b rpi-5.10.y https://github.com/raspberrypi/linux/ rpi-linux-5
    test -d rpi-linux-5 || exit 1
  else
    pushd rpi-linux-5
    git checkout rpi-5.10.y
    popd
  fi
  cd rpi-linux-5 || exit 1
  git format-patch -o ../rpi-patches-$RVER 77656fde3c0125d6ef6f7fb46af6d2739d7b7141
  cd ..
  #rm -fr rpi-linux-5
fi

if ! test -d linux-5 ; then
  #git clone --single-branch --depth 1 -b bullseye https://salsa.debian.org/kernel-team/linux.git linux-5
  git clone --single-branch --depth 1 -b 5.10-stable-updates https://salsa.debian.org/carnil/linux.git linux-5
fi
# Change Debian source to new version:
sed -i -e '1 s/5.10.102/5.10.103/' linux-5/debian/changelog
sed -i -e '1 s/unstable/UNRELEASED/' linux-5/debian/changelog
sed -i -e '1 s/experimental/UNRELEASED/' linux-5/debian/changelog
sed -i -e '1 s/bullseye/UNRELEASED/' linux-5/debian/changelog
#sed -i -e 's,^bugfix/all/bpf-Add-kconfig-knob-for-disabling-unpriv-bpf-by-def.patch,,g' linux-5/debian/patches/series
#sed -i -e 's,0104-printk-introduce-kernel-sync-mode.patch,,g' linux-5/debian/patches-rt/series
sed -i -e 's/CONFIG_DRM_AST=m/#CONFIG_DRM_AST is not set/g' linux-5/debian/config/arm64/config
sed -i -e 's/^ast//g' linux-5/debian/installer/modules/arm64/fb-modules
#exit 0
test -f orig/linux_$KVER.orig.tar.xz || wget -q https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KVER.tar.xz
cd linux-5 || exit 1
test -f ../orig/linux_$KVER.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py ../linux-$KVER.tar.xz
# Just to safe disk space and have a faster compile:
export DEBIAN_KERNEL_DISABLE_DEBUG=yes
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
# Disable RT kernel:
#if test $CROSS = 1 ; then
#  sed -i -e 's/^enabled: true/enabled: false/g' debian/config/defines
#fi
if test "$RPIPATCHES" = 1 ; then
  sed -i -e 's/--fuzz=0//g' debian/rules
  pushd debian/patches
    mkdir bugfix/rpi
    cp ../../../rpi.patch bugfix/rpi/
    #cp ../../../rpi-patches-$RVER/*.patch bugfix/rpi/
    #rm -f bugfix/rpi/0320-vc4_hdmi-Fix-register-offset-when-sending-longer-CEC.patch
    ls bugfix/rpi/*.patch >> series
  popd
  echo "CONFIG_PCIE_BRCMSTB=y" >> debian/config/config
  echo "CONFIG_RESET_RASPBERRY=y" >> debian/config/config
  echo "CONFIG_RESET_BRCMSTB_RESCAL=y" >> debian/config/config
  echo "CONFIG_NO_HZ_FULL=y" >> debian/config/featureset-rt/config
  rm -f debian/abi/5.10.0-*/arm*
fi
rm -fr debian/abi/5.10.0-*

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

