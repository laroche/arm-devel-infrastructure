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

KVER=6.9.8
KVERR=6.9.8
CDIR=linux-$KVERR
RVER=6.9.7

CROSS=0
ARCH=
if test "X$1" = "Xarm64" -o "X$1" = "Xrpi-arm64" ; then
  CROSS=1
  ARCH=arm64
  if test "X$1" = "Xrpi-arm64" ; then
    RPIPATCHES=1
  fi
  CDIR=$CDIR-arm64
fi
if test "X$1" = "Xarmhf" -o "X$1" = "Xrpi-armhf" ; then
  CROSS=1
  ARCH=armhf
  if test "X$1" = "Xrpi-armhf" ; then
    RPIPATCHES=1
  fi
  CDIR=$CDIR-armhf
fi

#export LANG=en_US.UTF-8

# Build requirements:
if true ; then
sudo apt-get -qq -y install build-essential fakeroot rsync git python3-debian libcap-dev g++-13
sudo apt-get -qq -y build-dep linux
if test $CROSS = 1 ; then
  sudo apt-get -qq -y install kernel-wedge quilt flex bison libssl-dev ccache
  sudo apt-get -qq -y install crossbuild-essential-arm64 crossbuild-essential-armhf
  sudo apt-get -qq -y install g++-13-aarch64-linux-gnu g++-13-arm-linux-gnueabihf
fi
fi

if test "$RPIPATCHES" = 1 -a ! -d rpi-patches-$RVER ; then
  # Extract the raspberry-pi patches into a subdirectory:
  RDIR=rpi-linux-$RVER
  if test ! -d $RDIR ; then
    git clone -b rpi-6.9.y https://github.com/raspberrypi/linux/ $RDIR
    test -d $RDIR || exit 1
  else
    pushd $RDIR
    git checkout rpi-6.9.y
    popd
  fi
  cd $RDIR || exit 1
  git format-patch -o ../rpi-patches-$RVER 12c740d50d4e74e6b97d879363b85437dc895dde
  cd ..
  rm -fr $RDIR
fi

if ! test -d $CDIR ; then
  #git clone --single-branch --depth 1 -b master https://salsa.debian.org/kernel-team/linux.git $CDIR
  git clone --single-branch --depth 1 -b 6.9-stable-updates https://salsa.debian.org/carnil/linux.git $CDIR
  #git clone --single-branch --depth 1 -b update-to-6.9.x https://salsa.debian.org/diederik/linux.git $CDIR
fi
sed -i -e '/install-rtla)/d' $CDIR/debian/rules.real
# Change Debian source to new version:
sed -i -e '1 s/6.9.8-/6.9.8-/' $CDIR/debian/changelog
sed -i -e '1 s/unstable/UNRELEASED/' $CDIR/debian/changelog
sed -i -e '1 s/experimental/UNRELEASED/' $CDIR/debian/changelog
#sed -i -e 's,^bugfix/all/tipc-fix-UAF-in-error-path.patch,,g' $CDIR/debian/patches/series
#sed -i -e 's,powerpc-imc-pmu-Use-the-correct-spinlock-initializer.patch,,g' $CDIR/debian/patches-rt/series
#exit 0
mkdir -p orig
cd $CDIR || exit 1
test -f ../orig/linux_$KVER.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
# Just to safe disk space and have a faster compile:
export DEBIAN_KERNEL_DISABLE_DEBUG=yes
sed -i -e 's/^debug-info: true/debug-info: false/g' debian/config/defines
sed -i -e 's/^CONFIG_DEBUG_INFO=y/# CONFIG_DEBUG_INFO is not set/g' debian/config/config
# Disable RT kernel:
#if test $CROSS = 1 ; then
#  sed -i -e 's/^enabled: true/enabled: false/g' debian/config/defines
#fi
if test "$RPIPATCHES" = 1 ; then
  sed -i -e 's/--fuzz=0//g' debian/rules
  pushd debian/patches
    mkdir bugfix/rpi
    cp ../../../rpi-patches-$RVER/*.patch bugfix/rpi/
    rm -f bugfix/rpi/0434-cfg80211-ship-debian-certificates-as-hex-files.patch
    rm -f bugfix/rpi/0663-module-Avoid-ABI-changes-when-debug-info-is-disabled.patch
    ls bugfix/rpi/*.patch >> series
  popd
  echo "CONFIG_PCIE_BRCMSTB=y" >> debian/config/config
  echo "CONFIG_RESET_RASPBERRY=y" >> debian/config/config
  echo "CONFIG_RESET_BRCMSTB_RESCAL=y" >> debian/config/config
  echo "CONFIG_NO_HZ_FULL=y" >> debian/config/featureset-rt/config
  rm -f debian/abi/6.9.0-*/arm*
fi
rm -fr debian/abi/6.9.0-*

if test $CROSS = 0 ; then

debian/rules orig
debian/rules debian/control
#debian/rules source
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
#export DEBUG_INFO=n

fakeroot make -f debian/rules clean
fakeroot make -f debian/rules orig
fakeroot make -f debian/rules source
fakeroot make -f debian/rules.gen setup_${ARCH}
sed -i 's/binary-arch_arm64:: binary-arch_arm64_none binary-arch_arm64_real/binary-arch_arm64:: binary-arch_arm64_none/' debian/rules.gen
sed -i 's/binary-arch_armhf:: binary-arch_armhf_extra binary-arch_armhf_none binary-arch_armhf_real/binary-arch_armhf:: binary-arch_armhf_extra binary-arch_armhf_none/' debian/rules.gen
fakeroot make -f debian/rules.gen binary-arch_${ARCH} 2>&1 | tee LOG

fi

cd ..

rm -f *-dbg_*.deb
if test $CROSS = 0 ; then
  L=kernel-amd64-$KVERR-1
  mkdir -p $L
  mv $CDIR/LOG *$KVERR*amd64.deb $L
  tar cplf - $L | gzip -9 > $L.tar.gz
  rm -fr $L
else
  L=kernel-rpi3-$ARCH-$KVERR-1
  mkdir -p $L
  mv $CDIR/LOG *$KVERR*$ARCH.deb $L
  if test $ARCH = armhf ; then
    mv *$KVERR*.udeb $L
  fi
  tar cplf - $L | gzip -9 > $L.tar.gz
  rm -fr $L
fi

rm -fr $CDIR

