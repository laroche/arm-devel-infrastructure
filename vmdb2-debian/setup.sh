#!/bin/bash
#
# After booting a new generic Debian image, you can user this sample script
# to automatically adjust your image to your personal taste/needs.
#
# Many items in this script are more for a personal development box and
# not suited for a server image with security hardening.
#

NEWUSER=max

# Non-root adjustments that can be done after running setup.sh as root:
if test "X$UID" != "X0" ; then
  # https://superuser.com/questions/394376/how-to-prevent-gnome-shells-alttab-from-grouping-windows-from-similar-apps
  #dconf write /org/gnome/desktop/wm/keybindings/switch-applications
  #dconf write /org/gnome/desktop/wm/keybindings/switch-applications-backward
  #dconf write /org/gnome/desktop/wm/keybindings/switch-windows "['<Super>Tab', '<Alt>Tab']"
  #dconf write /org/gnome/desktop/wm/keybindings/switch-windows-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-windoes "['<Super>Tab', '<Alt>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-windoes-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
  #gsettings set org.gnome.shell.window-switcher current-workspace-only true
  exit 0
fi

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
testing="0"
if grep -q testing /etc/apt/sources.list ; then
  testing="1"
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
if test $unstable = 1 -o $testing = 1 ; then
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
  $apt install firefox-esr firefox-esr-l10n-de vlc
  if test $testing = 0 ; then
    $apt install chromium chromium-l10n
  fi
  $apt install libreoffice libreoffice-help-de libreoffice-l10n-de
  $apt install rdesktop dconf-editor imagemagick mesa-utils inxi
  $apt install network-manager-openconnect-gnome

  # Allow X11 apps over ssh to work:
  $apt install xauth

  # virtualization support:
  $apt install virtinst virt-manager libguestfs-tools

  $apt install qemu-system-arm qemu-efi minicom

  # Google chrome browser: (https://wiki.debian.org/DebianRepository/Unofficial)
  if test "$HOSTTYPE" = "x86_64" ; then
    #wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    #$apt install ./google-chrome-stable_current_amd64.deb
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
    apt update
    $apt install google-chrome-stable
  fi

  # Eclipse
  if test "$HOSTTYPE" = "x86_64" ; then
  if ! test -e /usr/bin/eclipse ; then
    wget -q http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/2019-09/R/eclipse-cpp-2019-09-R-linux-gtk-x86_64.tar.gz
    tar -zxf eclipse-cpp-2019-09-R-linux-gtk-x86_64.tar.gz -C /usr
    ln -s /usr/eclipse/eclipse /usr/bin/eclipse
    rm -f eclipse-cpp-2019-09-R-linux-gtk-x86_64.tar.gz
    cat > /usr/share/applications/eclipse.desktop <<EOM
[Desktop Entry]
Encoding=UTF-8
Name=Eclipse IDE
Comment=Eclipse IDE
Exec=/usr/bin/eclipse
Icon=/usr/eclipse/icon.xpm
Categories=Application;Development;Java;IDE
Version=4.8
Type=Application
Terminal=0
EOM
  fi
  $apt install default-jre
  fi

  # visual studio code from https://code.visualstudio.com/docs/setup/linux
  if test "$HOSTTYPE" = "x86_64" ; then
  if ! test -f /usr/share/keyrings/packages.microsoft.gpg ; then
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg
  fi
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
  #$apt install apt-transport-https
  apt update
  $apt install code # or code-insiders
  $apt install gvfs-bin
  #update-alternatives --set editor /usr/bin/code
  #echo "fs.inotify.max_user_watches=524288" > /etc/sysctl.d/10-visual-studio-code.conf
  # Launch VS Code Quick Open (Ctrl+P): ext install ms-vscode.cpptools
  # Launch VS Code Quick Open (Ctrl+P): ext install ms-python.python
  fi

  if test "$HOSTTYPE" = "x86_64" ; then
    if ! test -f /var/lib/dpkg/arch ; then
      dpkg --add-architecture i386
      apt update
    fi
    $apt install wine winetricks wine32
  fi
fi
# Company dependent apps:
if false ; then
  $apt install rdesktop
  $apt install qttools5-dev qttools5-dev-tools
fi

# Generic devel environment:
$apt install build-essential autoconf libtool libtool-bin pkg-config bison flex git libacl1-dev libssl-dev
$apt install gawk bc make git-email ccache indent gperf exuberant-ctags
#$apt install perl clang golang
#$apt install python pylint pyflakes pyflakes3
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
  $apt install quotatool
  if ! test -d /home/$NEWUSER/data/ltp ; then
    su $NEWUSER -c "cd ~/data && git clone --depth 1 https://github.com/linux-test-project/ltp"
    cat > /opt/ltp-SKIP <<EOM
msgstress04
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
if test $unstable = 0 -a $testing = 0 -a ! -d /opt/qemu ; then
  $apt install pkg-config libglib2.0-dev libpixman-1-dev
  if ! test -f /home/$NEWUSER/data/qemu-4.2.0.tar.xz ; then
    su $NEWUSER -c "cd ~/data && wget -q https://download.qemu.org/qemu-4.2.0.tar.xz"
  fi
  #tar xJf qemu-4.2.0.tar.xz
  #cd qemu-4.2.0
  #./configure --prefix=/opt/qemu
  #make -j 8
  #sudo make install
fi

apt clean
apt update

# If this should again be used as a generic image:
#dd if=/dev/zero of=/ZERO; rm -f /ZERO # zero unused filesystem

