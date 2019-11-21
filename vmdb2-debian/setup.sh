#!/bin/bash
#
# After booting a new generic Debian image, you can user this sample script
# to automatically adjust your image to your personal taste/needs.
#
# Many items in this script are more for a personal development box and
# not suited for a server image with security hardening.
#

NEWUSER=max

# check if we run as root
if test "X$UID" != "X0" ; then
  echo "Please run as root."
  exit 1
fi

apt="apt -q -y"

unstable="0"
if grep -q unstable /etc/apt/sources.list ; then
  unstable="1"
fi

if false ; then
if test -b /dev/sda && ! test -b /dev/sda2 ; then
  parted -s -- /dev/sda mkpart primary linux-swap -4096 -0
  if test -b /dev/sda2 ; then
    mkswap -L DEBSWAP /dev/sda2
  fi
  # enable swap
  sed -i -e 's/^#LABEL/LABEL/g' /etc/fstab
  swapon -a
  #free
  # Automated resizing sda1 does not work with parted, you need
  # to execute this manually:
  #parted -s -- /dev/sda resizepart 1 -4096
  #resize2fs /dev/sda1
fi
fi

# On first boot with the new Linux system, extend the filesystem to the
# end of the disk and add a Linux swap-partition to the end of the disk
# with the following commands:
# - parted /dev/sda
#   (parted) mkpart primary linux-swap -4096 -0
#   (parted) resizepart 1
#     -4096
# - resize2fs /dev/sda1
# - mkswap -L DEBSWAP /dev/sda2
# - edit /etc/fstab
# - swapon -a

# Add NOPASSWD so that all users in the sudo group do not have to type in their password:
# This is not recommended and insecure, but handy on some devel machines.
sed -i -e 's/^%sudo.*/%sudo\tALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

# vim package updates overwrite this change, so we need to fix this periodically:
# https://unix.stackexchange.com/questions/318824/vim-cutpaste-not-working-in-stretch-debian-9
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=864074
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=837761#76
if test $unstable = 1 ; then
  sed -i -e '/has.*mouse/,+6s/^/"/' /usr/share/vim/vim81/defaults.vim
else
  sed -i -e '/has.*mouse/,+2s/^/"/' /usr/share/vim/vim81/defaults.vim
fi

# disable ipv6
#sed -i -e 's/^#//g' /etc/sysctl.d/01-disable-ipv6.conf

# Add myself:
if ! test -d /home/$NEWUSER ; then
  adduser --gecos "Max Mustermann" --add_extra_groups --disabled-password $NEWUSER
  sed -i -e "s/^$NEWUSER:[^:]*:/$NEWUSER::/g" /etc/shadow
  adduser $NEWUSER sudo
fi
if ! test -d /home/$NEWUSER/data ; then
  su $NEWUSER -c "mkdir -p ~/data"
fi
if ! test -d /home/$NEWUSER/.ssh ; then
  su $NEWUSER -c "mkdir -m 0700 -p ~/.ssh"
fi

# Run updates:
apt update
$apt dist-upgrade

# Install some GUI and desktop apps:
if false ; then
  #$apt install xfce4 lightdm synaptic menu
  #$apt install aptitude
  tasksel install gnome-desktop --new-install
  $apt install firefox-esr firefox-esr-l10n-de chromium chromium-l10n vlc
  $apt install libreoffice libreoffice-help-de libreoffice-l10n-de
  $apt install rdesktop dconf-editor imagemagick
  # https://superuser.com/questions/394376/how-to-prevent-gnome-shells-alttab-from-grouping-windows-from-similar-apps
  #dconf write /org/gnome/desktop/wm/keybindings/switch-applications
  #dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward
  #dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Super>Tab', '<Alt>Tab']"
  #dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
  #gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
  #gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
  #gsettings set org.gnome.shell.window-switcher current-workspace-only true

  # virtualization support:
  $apt install virtinst virt-manager

  $apt install qemu-system-arm qemu-efi minicom
fi
# Company dependent apps:
if false ; then
  $apt install rdesktop
  $apt install qttools5-dev qttools5-dev-tools
fi

# Generic devel environment:
$apt install build-essential autoconf libtool libtool-bin pkg-config bison flex git libacl1-dev libssl-dev
$apt install gawk bc make git-email ccache indent gperf
#$apt install python perl clang golang
#$apt install subversion git-svn
#$apt install openjdk-8-jdk cmake
#$apt install gcc-arm-none-eabi g++-aarch64-linux-gnu g++-arm-linux-gnueabihf

# Checkout some devel projects:
if true ; then
  if ! test -d /home/$NEWUSER/data/arm-devel-infrastructure ; then
    su $NEWUSER -c "cd ~/data && git clone https://github.com/laroche/arm-devel-infrastructure"
  fi
  $apt install vmdb2 dosfstools qemu qemu-user-static make zip
fi
if ! test -d /opt/ltp ; then
  if ! test -d /home/$NEWUSER/data/ltp ; then
    su $NEWUSER -c "cd ~/data && git clone --depth 1 https://github.com/linux-test-project/ltp"
    cat > /opt/ltp-SKIP <<EOM
msgstress04
pivot_root01
userns07
memcg_max_usage_in_bytes
memcg_stat
memcg_use_hierarchy
memcg_usage_in_bytes
nm01_sh
crypto_user02
zram01
zram02
zram03
EOM
    # make autotools
    # ./configure
    # make -j 8
    # sudo make install
  fi
fi
if test $unstable = 0 -a ! -d /opt/qemu ; then
  $apt install pkg-config libglib2.0-dev libpixman-1-dev
  if ! test -f /home/$NEWUSER/data/qemu-4.1.0.tar.xz ; then
    su $NEWUSER -c "cd ~/data && wget -q https://download.qemu.org/qemu-4.1.0.tar.xz"
  fi
  #tar xJf qemu-4.1.0.tar.xz
  #cd qemu-4.1.0
  #./configure --prefix=/opt/qemu
  #make -j 8
  #sudo make install
fi

