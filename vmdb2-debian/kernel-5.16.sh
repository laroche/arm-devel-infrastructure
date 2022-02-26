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

KVER=5.16.11
CDIR=linux-$KVER
RVER=5.16.10

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
sudo apt-get -qq -y install build-essential fakeroot rsync git python3-debian libcap-dev g++-11
sudo apt-get -qq -y build-dep linux
if test $CROSS = 1 ; then
  sudo apt-get -qq -y install kernel-wedge quilt flex bison libssl-dev ccache
  sudo apt-get -qq -y install crossbuild-essential-arm64 crossbuild-essential-armhf
  sudo apt-get -qq -y install g++-11-aarch64-linux-gnu g++-11-arm-linux-gnueabihf
fi
fi

if test "$RPIPATCHES" = 1 -a ! -d rpi-patches-$RVER ; then
  # Extract the raspberry-pi patches into a subdirectory:
  if test ! -d rpi-linux-5 ; then
    git clone -b rpi-5.16.y https://github.com/raspberrypi/linux/ rpi-linux-5
    test -d rpi-linux-5 || exit 1
  else
    pushd rpi-linux-5
    git checkout rpi-5.16.y
    popd
  fi
  cd rpi-linux-5 || exit 1
  git format-patch -o ../rpi-patches-$RVER 528cecfa5af09631f0589efe9eacbd543c8c9db1
  cd ..
  #rm -fr rpi-linux-5
fi

if ! test -d $CDIR ; then
  git clone --single-branch --depth 1 -b sid https://salsa.debian.org/kernel-team/linux.git $CDIR
fi
# Change Debian source to new version:
#sed -i -e '1 s/5.16.10/5.16.11/' $CDIR/debian/changelog
sed -i -e '1 s/unstable/UNRELEASED/' $CDIR/debian/changelog
sed -i -e '1 s/experimental/UNRELEASED/' $CDIR/debian/changelog
#sed -i -e 's,^bugfix/all/iwlwifi-fix-use-after-free.patch,,g' $CDIR/debian/patches/series
#sed -i -e 's,0038-powerpc-mm-highmem-Switch-to-generic-kmap-atomic.patch,,g' $CDIR/debian/patches-rt/series
sed -i -e 's/CONFIG_DRM_AST=m/#CONFIG_DRM_AST is not set/g' $CDIR/debian/config/arm64/config
sed -i -e 's/^ast//g' $CDIR/debian/installer/modules/arm64/fb-modules
#exit 0
mkdir -p orig
cd $CDIR || exit 1
test -f ../orig/linux_$KVER.orig.tar.xz || XZ_DEFAULTS="-T 0" debian/bin/genorig.py https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
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
    cp ../../../rpi-patches-$RVER/*.patch bugfix/rpi/
    rm -f bugfix/rpi/0573-brcmfmac-firmware-Fix-crash-in-brcm_alt_fw_path.patch
    ls bugfix/rpi/*.patch >> series
  popd
  echo "CONFIG_PCIE_BRCMSTB=y" >> debian/config/config
  echo "CONFIG_RESET_RASPBERRY=y" >> debian/config/config
  echo "CONFIG_RESET_BRCMSTB_RESCAL=y" >> debian/config/config
  echo "CONFIG_NO_HZ_FULL=y" >> debian/config/featureset-rt/config
  rm -f debian/abi/5.16.0-*/arm*
fi
rm -fr debian/abi/5.16.0-*

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
fakeroot make -f debian/rules.gen binary-arch_${ARCH} 2>&1 | tee LOG

fi

cd ..

if test $CROSS = 0 ; then
  L=kernel-amd64-$KVER-1
  mkdir -p $L
  mv $CDIR/LOG *.deb $L
  tar cplf - $L | gzip -9 > $L.tar.gz
  rm -fr $L
else
  L=kernel-rpi3-$ARCH-$KVER-1
  mkdir -p $L
  mv $CDIR/LOG *.deb $L
  tar cplf - $L | gzip -9 > $L.tar.gz
  rm -fr $L
fi

