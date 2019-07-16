#!/bin/bash
#
# After booting a new generic image, you can user this sample script to
# automatically adjust your image to your personal taste/needs.
#
# Many items in this script are more for a personal development box and
# not suited for a server image with security hardening.
#

# check if we run as root
if test "X$UID" != "X0" ; then
  echo "Please run as root."
  exit 1
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
sed -i -e 's/^%sudo.*/%sudo\tALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers

# vim package updates overwrite this change, so we need to fix this periodically:
sed -i -e '/has.*mouse/,+2s/^/"/' /usr/share/vim/vim81/defaults.vim

# disable ipv6
#sed -i -e 's/^#//g' /etc/sysctl.d/01-disable-ipv6.conf

# enable swap
#sed -i -e 's/^#LABEL/LABEL/g' /etc/fstab

# Add myself:
if ! test -d /home/max ; then
  adduser --gecos "Max Mustermann" --add_extra_groups --disabled-password max
  sed -i -e 's/^max:[^:]*:/max::/g' /etc/shadow
  adduser max sudo
fi
if ! test -d ~max/data ; then
  su max -c "mkdir -p ~/data"
fi
if ! test -d ~max/.ssh ; then
  su max -c "mkdir -m 0700 -p ~/.ssh"
fi

# Run updates:
apt update
apt -q -y dist-upgrade

# Install some GUI and desktop apps:
if false ; then
  #apt -q -y install xfce4 lightdm synaptic menu
  apt -q -y install aptitude
  tasksel install gnome-desktop --new-install
  apt -q -y install firefox-esr firefox-esr-l10n-de chromium chromium-l10n vlc
  apt -q -y install libreoffice libreoffice-help-de libreoffice-l10n-de
  apt -q -y install rdesktop dconf-editor
  # https://superuser.com/questions/394376/how-to-prevent-gnome-shells-alttab-from-grouping-windows-from-similar-apps
  #dconf write /org/gnome/desktop/wm/keybindings/switch-applications
  #dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward
  #dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Super>Tab', '<Alt>Tab']"
  #dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
  #gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
  #gsettings set org.gnome.shell.window-switcher current-workspace-only true
fi
# Company dependent apps:
if false ; then
  apt -q -y install cntlm rdesktop
  apt -q -y install qttools5-dev qttools5-dev-tools
fi

# Generic devel environment:
apt -q -y install build-essential autoconf libtool libtool-bin bison flex git libacl1-dev libssl-dev
apt -q -y install gawk bc make git-email ccache indent gperf
#apt -q -y install python perl clang golang
#apt -q -y install subversion git-svn
#apt -q -y install openjdk-8-jdk cmake
#apt -q -y install qemu-system-arm qemu-efi minicom
#apt -q -y install gcc-arm-none-eabi g++-aarch64-linux-gnu
#apt -q -y install g++-9-aarch64-linux-gnu g++-9-arm-linux-gnueabihf
apt -q -y install virtinst virt-manager

# Checkout some devel projects:
if true ; then
  if ! test -d ~max/data/arm-devel-infrastructure ; then
    su max -c "cd ~/data && git clone https://github.com/laroche/arm-devel-infrastructure"
  fi
  apt -q -y install vmdb2 dosfstools qemu qemu-user-static make zip
fi
if ! test -d /opt/ltp ; then
  #apt -q -y install build-essential autoconf libtool libtool-bin bison flex git libacl1-dev libssl-dev
  if ! test -d ~max/data/ltp ; then
    su max -c "cd ~/data && git clone --depth 1 https://github.com/linux-test-project/ltp"
    # make autotools
    # ./configure
    # make -j 6
    # sudo make install
  fi
fi
if ! test -d /opt/qemu ; then
  apt -q -y install libglib2.0-dev pkg-config libpixman-1-dev
  if ! test -f ~flaroche/data/qemu-4.1.0-rc0.tar.xz ; then
    su flaroche -c "cd ~/data && wget https://download.qemu.org/qemu-4.1.0-rc0.tar.xz"
  fi
  #tar xJf qemu-4.1.0-rc0.tar.xz
  #cd qemu-4.1.0-rc0
  #./configure --prefix=/opt/qemu
  #make -j 4
  #sudo make install
fi

