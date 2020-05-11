#!/bin/bash
#
# After booting a new generic Debian image, you can use this sample script
# to automatically adjust your image to your personal taste/needs.
#
# Many items in this script are more for a personal development box and
# not suited for a server image with security hardening.
#
# Further configuration steps you might consider:
# - Set password for root and $NEWUSER.
# - Add ~$NEWUSER/.ssh/ and ~$NEWUSER/.gitconfig
# - Add firewall rules.
# - Gnome setup:
#   - Vorgabe-Anwendungen: Web: Google Chrome, Musik/Video: VLC Media Player, Fotos: ImageMagick
#   - Einstellungen/Energie: In Bereitschaft gehen: disable
# - browsers chrome/firefox: Tabs von zuletzt verwenden
# - Add hostname to /etc/hosts if no DNS is available (otherwise sudo to slow).
# - If on a virtualized setup, maybe set screen size to 1600x900.
#

NEWUSER=max
GECOS="Max Mustermann"

# Non-root adjustments that can be done after running setup.sh as root:
if test "X$UID" != "X0" ; then
  # https://superuser.com/questions/394376/how-to-prevent-gnome-shells-alttab-from-grouping-windows-from-similar-apps
  gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab', '<Alt>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab', '<Shift><Alt>Tab']"
  #gsettings set org.gnome.shell.window-switcher current-workspace-only true
  # add min/max to title:
  gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
  # list of favorites on the gnome desktop
  gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'google-chrome.desktop', 'firefox-esr.desktop', 'code.desktop', 'libreoffice-writer.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop', 'yelp.desktop']"
  # Set gnome-terminal to 120x40 and dark color:
  PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default)
  PROFILE=${PROFILE:1:-1} # remove leading and trailing single quotes
  gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" default-size-columns 120
  gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" default-size-rows 40
  gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/" use-theme-colors false
  # 30 min until we disable the screen
  gsettings set org.gnome.desktop.session idle-delay 1800
  # disable screen saver
  gsettings set org.gnome.desktop.screensaver lock-delay 0
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

delim="---------------------------------------------------------------------------------"
newlog() {
  echo $delim
  echo $*
}


# This can be run anytime to check the status of the machine:
if test "X$1" = Xcheck ; then
  newlog "List failed systemctl jobs:"
  systemctl list-units --state=failed
  newlog "List all *.ucf-dist* files in /etc /usr:"
  find /etc /usr -name "*.ucf-dist*"
  newlog "List all debian packages not in state ii:"
  dpkg -l | grep -v ^ii
  newlog "List all debian packages named linux-image:"
  dpkg -l | grep linux-image
  newlog "List all regular files in /tmp /var/tmp:"
  find /tmp /var/tmp -type f
  newlog "List all regular files in /var/cache/apt:"
  find /var/cache/apt -type f
  newlog "Run updates via apt:"
  apt update
  $apt dist-upgrade
  #$apt autoremove
  #newlog "List all regular files in /var/cache/apt:"
  #find /var/cache/apt -type f
  #apt clean
  newlog "All checks finished."
  exit 0
fi


if false ; then
# Extend to a bigger disk and create a swap partition:
if test -b /dev/debvg/rootfs -a -b /dev/sda1 ; then
  if ! test -b /dev/debvg/swapfs ; then
    echo "Trying to extend the disk and create a swap partition:"
    parted -s -- /dev/sda resizepart 1 100%
    pvresize /dev/sda1
    lvextend -L +11G /dev/debvg/rootfs
    resize2fs /dev/debvg/rootfs
    lvcreate --name swapfs --size 8G debvg
    if test -b /dev/debvg/swapfs ; then
      mkswap -L DEBSWAP /dev/debvg/swapfs
      sed -i -e 's/^#LABEL/LABEL/g' /etc/fstab
      swapon -a
    fi
    lvcreate --name homefs --size 1G debvg
    if test -b /dev/debvg/homefs ; then
      mkfs.ext4 /dev/debvg/homefs
      echo -e "/dev/debvg/homefs\t/home\text4\tdefaults 0 0" >> /etc/fstab
      mount -a
    fi
  fi
fi
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
vim="/usr/share/vim/vim82/defaults.vim"
if ! test -f $vim ; then
  vim="/usr/share/vim/vim81/defaults.vim"
fi
if test -f $vim ; then
  if test $unstable = 1 -o $testing = 1 ; then
    sed -i -e '/has.*mouse/,+6s/^/"/' $vim
  else
    sed -i -e '/has.*mouse/,+2s/^/"/' $vim
  fi
fi

# disable ipv6
#sed -i -e 's/^#//g' /etc/sysctl.d/01-disable-ipv6.conf

# Add myself:
if ! test -d /home/$NEWUSER ; then
  adduser --gecos "$GECOS" --add_extra_groups --disabled-password $NEWUSER
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
$apt autoremove

# Install some GUI and desktop apps:
if false ; then
  #$apt install xfce4 lightdm synaptic menu
  #$apt install aptitude
  tasksel install gnome-desktop --new-install
  $apt install firefox-esr firefox-esr-l10n-de vlc chromium chromium-l10n
  $apt install libreoffice libreoffice-help-de libreoffice-l10n-de
  $apt install rdesktop remmina dconf-editor imagemagick mesa-utils inxi
  $apt install network-manager-openconnect-gnome openvpn

  # Allow X11 apps over ssh to work:
  $apt install xauth

  # virtualization support:
  $apt install virtinst virt-manager libguestfs-tools

  $apt install meld

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
  if true && test "$HOSTTYPE" = "x86_64" ; then
    if ! test -e /usr/bin/eclipse ; then
      wget -q http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/2020-03/R/eclipse-cpp-2020-03-R-incubation-linux-gtk-x86_64.tar.gz
      tar -zxf eclipse-cpp-2020-03-R-incubation-linux-gtk-x86_64.tar.gz -C /usr
      ln -s /usr/eclipse/eclipse /usr/bin/eclipse
      rm -f eclipse-cpp-2020-03-R-incubation-linux-gtk-x86_64.tar.gz
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
  if true && test "$HOSTTYPE" = "x86_64" ; then
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

  # Windows emu wine:
  if false && test "$HOSTTYPE" = "x86_64" ; then
    if ! test -f /var/lib/dpkg/arch ; then
      dpkg --add-architecture i386
      apt update
    fi
    $apt install wine winetricks wine32
  fi

  # Microsoft Teams:
  if true && test "$HOSTTYPE" = "x86_64" -a ! -x /usr/bin/teams ; then
    wget -q -O teams.deb https://go.microsoft.com/fwlink/p/?linkid=2112886
    dpkg -i teams.deb
    rm -f teams.deb
  fi

  # Skype:
  if true && test "$HOSTTYPE" = "x86_64" -a ! -x /usr/bin/skypeforlinux ; then
    wget -q https://go.skype.com/skypeforlinux-64.deb
    dpkg -i skypeforlinux-64.deb
    rm -f skypeforlinux-64.deb
  fi

  # If we install GUI, we don't need server network setup:
  rm -f /etc/network/interfaces.d/eth0
fi
# Company dependent apps:
if false ; then
  $apt install rdesktop
  $apt install qttools5-dev qttools5-dev-tools
fi

# Generic devel environment:
$apt install build-essential autoconf libtool libtool-bin pkg-config bison flex git libacl1-dev libssl-dev
$apt install gawk bc make git-email ccache indent gperf exuberant-ctags patchutils
#$apt install perl clang golang
#$apt install python pylint pyflakes3 # pyflakes
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
if true && ! test -d /opt/ltp ; then
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
if true && test $unstable = 0 -a $testing = 0 -a ! -d /opt/qemu ; then
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

# Download and install newer kernel:
KABI=5.6.0-1
KVER=5.6.12-1
if true && test "$HOSTTYPE" = "x86_64" && ! test -d /lib/modules/${KABI}-amd64 ; then
  KERNEL=kernel-amd64-$KVER.tar.gz
  wget -q https://github.com/laroche/arm-devel-infrastructure/releases/download/v20200419/$KERNEL
  tar xzf $KERNEL
  dpkg -i kernel-amd64-$KVER/linux-image-${KABI}-amd64-unsigned_${KVER}_amd64.deb
  rm -fr $KERNEL kernel-amd64-$KVER
fi

apt clean
apt update

# If this should again be used as a generic image:
#dd if=/dev/zero of=/ZERO || rm -f /ZERO # zero unused filesystem

