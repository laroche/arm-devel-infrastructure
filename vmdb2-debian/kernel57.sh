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
sudo apt-get -qq -y install build-essential fakeroot rsync git python3-debian libcap-dev
sudo apt-get -qq -y build-dep linux
if test $CROSS = 1 ; then
  sudo apt-get -qq -y install kernel-wedge quilt ccache flex bison libssl-dev
  sudo apt-get -qq -y install crossbuild-essential-arm64 crossbuild-essential-armhf
  #sudo apt-get -qq -y install g++-9-aarch64-linux-gnu g++-9-arm-linux-gnueabihf
fi
fi

KVER=5.7.6

if test $RPIPATCHES = 1 ; then
  #RVER=$KVER
  RVER=5.7.3
fi

if test "$RPIPATCHES" = 1 -a ! -d rpi-patches-$RVER ; then
  # Extract the raspberry-pi patches into a subdirectory:
  if test ! -d rpi-linux-5 ; then
    git clone -b rpi-5.7.y https://github.com/raspberrypi/linux/ rpi-linux-5
  else
    pushd rpi-linux-5
    git checkout rpi-5.7.y
    popd
  fi
  cd rpi-linux-5 || exit 1
  git format-patch -o ../rpi-patches-$RVER 264e468fc201cb81c313ad50924bb46506a1b31c
  cd ..
  #rm -fr rpi-linux-5
fi

if ! test -d linux-5 ; then
  git clone --single-branch --depth 1 -b master https://salsa.debian.org/kernel-team/linux.git linux-5
fi
# Change Debian source to new version:
#sed -i -e '1 s/5.7.4-1~exp1/5.7.5-1/' linux-5/debian/changelog
#sed -i -e 's,^bugfix/s390x/s390-mm-fix-page-table-upgrade-vs-2ndary-address-mod.patch,,g' linux-5/debian/patches/series
#sed -i -e 's,pci-switchtec-Don-t-use-completion-s-wait-queue.patch,,g' linux-5/debian/patches-rt/series
#exit 0
test -f orig/linux_$KVER.orig.tar.xz || wget -q https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KVER.tar.xz
cd linux-5 || exit 1
test -f ../orig/linux_$KVER.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py ../linux-$KVER.tar.xz
# Just to safe disk space and have a faster compile:
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
# Disable RT kernel:
#sed -i -e 's/^enabled: true/enabled: false/g' debian/config/defines
if test "$RPIPATCHES" = 1 ; then
  pushd debian/patches
    mkdir bugfix/rpi
    cp ../../../rpi-patches-$RVER/*.patch bugfix/rpi/
    rm -f bugfix/rpi/0293-media-i2c-Add-a-driver-for-the-Infineon-IRS1125-dept.patch \
          bugfix/rpi/0267-net-bcmgenet-Workaround-2-for-Pi4-Ethernet-fail.patch \
          bugfix/rpi/0334-bcmgenet-Disable-skip_umac_reset-by-default.patch \
          bugfix/rpi/0460-media-i2c-imx219-Fix-a-bug-in-imx219_enum_frame_size.patch \
          bugfix/rpi/0564-PCI-brcmstb-Assert-fundamental-reset-on-initializati.patch \
          bugfix/rpi/0578-media-irs1125-Using-i2c_transfer-for-ic2-reads.patch \
          bugfix/rpi/0579-media-irs1125-Refactoring-and-debug-messages.patch \
          bugfix/rpi/0580-media-irs1125-Atomic-access-to-imager-reconfiguratio.patch \
          bugfix/rpi/0581-media-irs1125-Keep-HW-in-sync-after-imager-reset.patch
    ls bugfix/rpi/*.patch >> series
  popd
  rm -f debian/abi/5.7.0-?/arm*
fi
rm -fr debian/abi/5.7.0-?

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

