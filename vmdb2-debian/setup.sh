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
# - Gnome setup:
#   - Vorgabe-Anwendungen: Web: Google Chrome, Musik/Video: VLC Media Player, Fotos: ImageMagick
#   - Einstellungen/Energie: In Bereitschaft gehen: disable
# - browsers chrome/firefox: Tabs von zuletzt verwenden
# - Set a new hostname in /etc/hostname.
# - Add hostname to /etc/hosts if no DNS is available (otherwise sudo is too slow, though seems fixed now).
# - If on a virtualized setup, maybe set screen size to 1600x900.
# - Setup printers.
#

# New user to setup:
NEWUSER=max
GECOS="Max Mustermann"

TIMEZONE="Europe/Berlin"

# Do we have a http proxy on this network? (IP:port or Hostname:port)
HTTP_PROXY=""

# Set sane setting to work with in the rest of the script:
umask 022


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

# Detect if we run for the first time:
FIRSTRUN=1
if test -d /home/$NEWUSER ; then
  FIRSTRUN=0
fi

SYSTYPE="$(systemd-detect-virt)"

apt="apt-get -qq -y"

DISTRO="debian"
if test -f /etc/lsb-release && grep -q Ubuntu /etc/lsb-release ; then
  DISTRO="ubuntu"
fi
unstable="0"
if grep -q unstable /etc/apt/sources.list || grep -qw sid /etc/apt/sources.list ; then
  unstable="1"
fi
testing="0"
if grep -q testing /etc/apt/sources.list || grep -q bullseye /etc/apt/sources.list ; then
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
  newlog "List all *.ucf-dist* and *.dpkg-dist files in /etc /usr:"
  find /etc /usr -name "*.ucf-dist*"
  find /etc /usr -name "*.dpkg-dist"
  newlog "List all debian packages not in state ii:"
  dpkg -l | grep -v ^ii
  newlog "List all debian packages named linux-image:"
  dpkg -l | grep linux-image
  newlog "List all regular files in /tmp /var/tmp:"
  find /tmp /var/tmp -type f
  newlog "List all regular files in /var/cache/apt:"
  find /var/cache/apt -type f
  newlog "Run updates via apt:"
  $apt update
  $apt dist-upgrade
  #$apt autoremove
  #newlog "List all regular files in /var/cache/apt:"
  #find /var/cache/apt -type f
  #$apt clean
  if test "X$SYSTYPE" != Xlxc -a -x /usr/bin/ntpq ; then
    newlog "ntp status:"
    /usr/bin/ntpq -p
  fi
  newlog "All checks finished."
  exit 0
fi


config_swapfile()
{
  test -f /swapfile && return
  #fallocate -l 8G /swapfile
  dd if=/dev/zero of=/swapfile bs=1M count=8192
  chmod 600 /swapfile
  mkswap -L DEBSWAP /swapfile
  swapon /swapfile
  echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
  # Use "swapon --show" or "cat /proc/swaps" or "free" to check system.
}

if test $FIRSTRUN = 1 ; then
if false ; then
# Extend to a bigger disk and create a swap partition:
if test -b /dev/debvg/rootfs -a -b /dev/sda1 ; then
  if ! test -b /dev/debvg/swapfs ; then
    echo "Trying to extend the disk and create a swap partition:"
    parted -s -- /dev/sda resizepart 1 100%
    pvresize /dev/sda1
    lvextend -L +13G /dev/debvg/rootfs
    resize2fs /dev/debvg/rootfs
    lvcreate --name swapfs --size 8G debvg
    if test -b /dev/debvg/swapfs ; then
      mkswap -L DEBSWAP /dev/debvg/swapfs
      sed -i -e 's/^#LABEL/LABEL/g' /etc/fstab
      swapon -a
    fi
    lvcreate --name homefs --size 3G debvg
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

# Bash configuration (aliases and .bashrc):
if ! test -f /root/.bash_aliases ; then
    cat > /root/.bash_aliases <<-EOM
	alias ..='cd ..'
	alias ...='cd ../..'
	alias o=less
	alias l='ls -la'
EOM
fi
if ! test -f /etc/skel/.bash_aliases ; then
  cp /root/.bash_aliases /etc/skel/.bash_aliases
fi
if ! grep -q bash_aliases /root/.bashrc ; then
    cat >> /root/.bashrc <<-EOM

	HISTCONTROL=ignoreboth
	# append to the history file, don't overwrite it
	shopt -s histappend
	HISTSIZE=1000
	HISTFILESIZE=2000

	. ~/.bash_aliases
EOM
fi

# disable ipv6
#sed -i -e 's/^#//g' /etc/sysctl.d/01-disable-ipv6.conf

if test "X$SYSTYPE" = Xlxc ; then
  # TODO XXX: Best would be to detect if we are running over ssh with "bash -s":
  export DEBIAN_FRONTEND=noninteractive
fi

if test "X$HTTP_PROXY" != "X" ; then
  if ! test -f /etc/apt/apt.conf.d/65proxy ; then
    cat > /etc/apt/apt.conf.d/65proxy <<-EOM
	Acquire::http::Proxy "http://$HTTP_PROXY/";
	#Acquire::https::Proxy "https://$HTTP_PROXY/";
EOM
  fi
  if test -d /etc/environment.d ; then
    if ! test -f /etc/environment.d/50proxy.conf ; then
      cat > /etc/environment.d/50proxy.conf <<-EOM
	http_proxy=http://$HTTP_PROXY/
	https_proxy=http://$HTTP_PROXY/
	ftp_proxy=http://$HTTP_PROXY/
	no_proxy=localhost
EOM
    fi
  elif ! grep -q http_proxy /etc/environment ; then
    cat >> /etc/environment <<-EOM
	http_proxy=http://$HTTP_PROXY/
	https_proxy=http://$HTTP_PROXY/
	ftp_proxy=http://$HTTP_PROXY/
	no_proxy=localhost
EOM
  fi
fi

config_timezone()
{
  echo "$TIMEZONE" > /etc/timezone
  ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
  #echo "tzdata tzdata/Areas select Europe" | debconf-set-selections
  #echo "tzdata tzdata/Zones/Europe select Berlin" | debconf-set-selections
  #dpkg-reconfigure --frontend=noninteractive tzdata
}

# On first run write a new sources.list file on Debian:
if test $FIRSTRUN = 1 ; then
  if test $DISTRO = debian ; then
  if test $testing = 1 ; then
      cat > /etc/apt/sources.list <<-EOM
	deb http://deb.debian.org/debian/ testing main contrib non-free
	deb-src http://deb.debian.org/debian/ testing main contrib non-free

	#deb http://deb.debian.org/debian/ testing-updates main contrib non-free
	#deb-src http://deb.debian.org/debian/ testing-updates main contrib non-free

	#deb http://deb.debian.org/debian-security testing-security main contrib non-free
	#deb-src http://deb.debian.org/debian-security testing-security main contrib non-free

	#deb http://security.debian.org testing-security main contrib non-free
EOM
  elif test $unstable = 1 ; then
      cat > /etc/apt/sources.list <<-EOM
	deb http://deb.debian.org/debian/ unstable main contrib non-free
	deb-src http://deb.debian.org/debian/ unstable main contrib non-free
EOM
  else
      cat > /etc/apt/sources.list <<-EOM
	deb http://deb.debian.org/debian/ buster main contrib non-free
	deb-src http://deb.debian.org/debian/ buster main contrib non-free

	deb http://deb.debian.org/debian/ buster-updates main contrib non-free
	deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free

	deb http://deb.debian.org/debian/ buster-backports main contrib non-free
	deb-src http://deb.debian.org/debian/ buster-backports main contrib non-free

	deb http://security.debian.org/debian-security buster/updates main contrib non-free
	deb-src http://security.debian.org/debian-security buster/updates main contrib non-free
EOM
  fi
  # Keep experimental commented out:
      cat > /etc/apt/sources.list.d/experimental.list <<-EOM
	#deb http://deb.debian.org/debian/ experimental main contrib non-free
	#deb-src http://deb.debian.org/debian/ experimental main contrib non-free
EOM
  fi
  config_timezone
fi

# Run updates:
#$apt clean
$apt update
if test $? != 0 ; then
  echo "Error running 'apt-get update', so exiting this script."
  exit 1
fi
$apt dist-upgrade
$apt autoremove

# On new systems install a base set of Debian packages:
if test $FIRSTRUN = 1 ; then
  # My own definition of a small Debian system:
  $apt install unattended-upgrades debsums locales locate psmisc strace htop \
    tree man parted lvm2 dosfstools vim sudo net-tools traceroute nmap \
    wakeonlan bind9-host dnsutils whois tcpdump iptables-persistent ssh openssh-server \
    screen tmux rsync curl wget git-core unzip zip xz-utils reportbug \
    less apt-utils
  # TODO: why less and apt-utils, they are already included in vmdb2
  #
  # Real hardware dependent packages we don't need within lxc:
  # irqbalance console-setup keyboard-configuration haveged ntp ntpdate
  # gpm wireless-tools wpasupplicant grub-pc firmware* linux-image*
fi

# Add NOPASSWD so that all users in the sudo group do not have to type in their password:
# This is not recommended and insecure, but handy on some devel machines.
if test -f /etc/sudoers ; then
  sed -i -e 's/^%sudo.*/%sudo\tALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
fi

# vim package updates overwrite this change, so we need to fix this periodically:
# https://unix.stackexchange.com/questions/318824/vim-cutpaste-not-working-in-stretch-debian-9
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=864074
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=837761#76
vim="/usr/share/vim/vim82/defaults.vim"
if ! test -f $vim ; then
  vim="/usr/share/vim/vim81/defaults.vim"
fi
if test $DISTRO = debian -a -f $vim ; then
  if test $unstable = 1 -o $testing = 1 ; then
    sed -i -e '/has.*mouse/,+6s/^/"/' $vim
  else
    sed -i -e '/has.*mouse/,+2s/^/"/' $vim
  fi
fi

update-alternatives --set editor /usr/bin/vim.basic

sed -i -e 's,^SHELL=/bin/sh,SHELL=/bin/bash,g' /etc/default/useradd

# Add myself:
if ! test -d /home/$NEWUSER ; then
  adduser --gecos "$GECOS" --add_extra_groups --disabled-password $NEWUSER
  # Disable password only for machines with a desktop and local login:
  if test "X$SYSTYPE" != Xlxc ; then
    sed -i -e "s/^$NEWUSER:[^:]*:/$NEWUSER::/g" /etc/shadow
  fi
  adduser $NEWUSER sudo
fi
if ! test -d /home/$NEWUSER/data ; then
  su $NEWUSER -c "mkdir -p ~/data"
fi
if ! test -d /home/$NEWUSER/.ssh ; then
  su $NEWUSER -c "mkdir -m 0700 -p ~/.ssh"
fi
if test -s /root/.ssh/authorized_keys && ! test -s /home/$NEWUSER/.ssh/authorized_keys ; then
  cp /root/.ssh/authorized_keys /home/$NEWUSER/.ssh/authorized_keys
  chown $NEWUSER.$NEWUSER /home/$NEWUSER/.ssh/authorized_keys
fi

INSTALLGUI=0
if test "X$SYSTYPE" = Xlxc ; then
  INSTALLGUI=0
fi
# Install some GUI and desktop apps:
if test "$INSTALLGUI" = 1 ; then
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
  $apt install virtinst virt-manager
  $apt install libguestfs-tools # XXX TODO: missing from Debian testing?

  $apt install meld

  $apt install qemu-system-arm qemu-efi minicom

  # Google chrome browser: (https://wiki.debian.org/DebianRepository/Unofficial)
  if test "$HOSTTYPE" = "x86_64" ; then
    #wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    #$apt install ./google-chrome-stable_current_amd64.deb
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
    $apt update
    $apt install google-chrome-stable
  fi

  # Eclipse
  if true && test "$HOSTTYPE" = "x86_64" ; then
    if ! test -e /usr/bin/eclipse ; then
      ECLIPSEVER=2020-06
      ECLIPSE=eclipse-cpp-${ECLIPSEVER}-R-linux-gtk-x86_64
      wget -q http://ftp.jaist.ac.jp/pub/eclipse/technology/epp/downloads/release/$ECLIPSEVER/R/$ECLIPSE.tar.gz
      tar -zxf $ECLIPSE.tar.gz -C /usr
      ln -s /usr/eclipse/eclipse /usr/bin/eclipse
      rm -f $ECLIPSE.tar.gz
      cat > /usr/share/applications/eclipse.desktop <<-EOM
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
    $apt update
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
      $apt update
    fi
    $apt install wine winetricks wine32
  fi

  # signal.ch messenger:
  if false && test "$HOSTTYPE" = "x86_64" ; then
    curl -s https://updates.signal.org/desktop/apt/keys.asc | apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" > /etc/apt/sources.list.d/signal-xenial.list
    $apt update
    $apt install signal-desktop
  fi

  # Microsoft Teams:
  if true && test "$HOSTTYPE" = "x86_64" -a ! -x /usr/bin/teams ; then
    wget -q -O teams.deb https://go.microsoft.com/fwlink/p/?linkid=2112886
    dpkg -i teams.deb
    rm -f teams.deb
  fi

  # Skype (disabled by default):
  if false && test "$HOSTTYPE" = "x86_64" -a ! -x /usr/bin/skypeforlinux ; then
    wget -q https://go.skype.com/skypeforlinux-64.deb
    dpkg -i skypeforlinux-64.deb
    rm -f skypeforlinux-64.deb
  fi

  # Teamviewer
  if false && test "$HOSTTYPE" = "x86_64" -a ! -f /etc/apt/sources.list.d/teamviewer.list ; then
    wget -q https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
    $apt install ./teamviewer_amd64.deb
    #dpkg -i teamviewer_amd64.deb
    rm -f teamviewer_amd64.deb
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
$apt install build-essential gcc-doc autoconf libtool libtool-bin pkg-config bison flex git libacl1-dev libssl-dev
$apt install gawk bc make git-email ccache indent gperf exuberant-ctags patchutils info
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
if false && ! test -d /opt/ltp ; then
  $apt install quotatool
  if ! test -d /home/$NEWUSER/data/ltp ; then
    su $NEWUSER -c "cd ~/data && git clone --depth 1 https://github.com/linux-test-project/ltp"
    cat > /opt/ltp-SKIP <<-EOM
	fallocate06
	fanotify15
	msgstress04
	fs_fill
	ksm03
	ksm03_1
	ksm04
	ksm04_1
	oom03
	oom05
	pty04
	userns07
	memcg_max_usage_in_bytes
	memcg_stat
	memcg_use_hierarchy
	memcg_usage_in_bytes
	cpuset_inherit
	cpuset_hotplug
	crypto_user02
EOM
    # make autotools
    # ./configure
    # make -j 8
    # sudo make install
  fi
fi
if true && test $DISTRO = debian -a $unstable = 0 -a $testing = 0 -a ! -d /opt/qemu ; then
  $apt install pkg-config libglib2.0-dev libpixman-1-dev
  QEMUVER=5.1.0
  QEMU=qemu-$QEMUVER
  if ! test -f /home/$NEWUSER/data/$QEMU.tar.xz ; then
    su $NEWUSER -c "cd ~/data && wget -q https://download.qemu.org/$QEMU.tar.xz"
  fi
  #tar xJf $QEMU.tar.xz
  #cd $QEMU
  #./configure --prefix=/opt/qemu
  #make -j 8
  #sudo make install
fi

# Download and install newer kernel:
KABI=5.8.0-2
KVER=5.8.12-1
# Disabled by default as check for KABI is not enough:
if false && test "$HOSTTYPE" = "x86_64" && ! test -d /lib/modules/${KABI}-amd64 ; then
  KERNEL=kernel-amd64-$KVER.tar.gz
  wget -q https://github.com/laroche/arm-devel-infrastructure/releases/download/v20200927/$KERNEL
  tar xzf $KERNEL
  dpkg -i kernel-amd64-$KVER/linux-image-${KABI}-amd64-unsigned_${KVER}_amd64.deb
  rm -fr $KERNEL kernel-amd64-$KVER
fi

config_firewall()
{
  {
    cat <<-EOM
	*filter
	:INPUT DROP [0:0]
	:FORWARD ACCEPT [0:0]
	:OUTPUT ACCEPT [0:0]
	-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
EOM
    for i in $1 ; do
      echo "-A INPUT -p tcp -m tcp --dport $i -j ACCEPT"
    done
    cat <<-EOM
	-A INPUT -p udp -m udp --sport 67:68 --dport 67:68 -j ACCEPT
	-A INPUT -i lo -j ACCEPT
	-A INPUT -p icmp -j ACCEPT
	-A INPUT -j REJECT --reject-with icmp-host-prohibited
	COMMIT
	*nat
	:PREROUTING ACCEPT [0:0]
	:INPUT ACCEPT [0:0]
	:POSTROUTING ACCEPT [0:0]
	:OUTPUT ACCEPT [0:0]
	COMMIT
EOM
  } > /etc/iptables/rules.v4
  {
    cat <<-EOM
	*filter
	:INPUT DROP [0:0]
	:FORWARD ACCEPT [0:0]
	:OUTPUT ACCEPT [0:0]
	-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
EOM
    for i in $2 ; do
      echo "-A INPUT -p tcp -m tcp --dport $i -j ACCEPT"
    done
    cat <<-EOM
	-A INPUT -i lo -j ACCEPT
	-A INPUT -p ipv6-icmp -j ACCEPT
	-A INPUT -j REJECT --reject-with icmp6-adm-prohibited
	COMMIT
EOM
  } > /etc/iptables/rules.v6
}

# lxc server:
config_lxc()
{
  $apt install lxc
  #lxc-checkconfig
  cat > /etc/lxc/default.conf <<-EOM
	#lxc.net.0.type = empty
	lxc.net.0.type = veth
	lxc.net.0.link = lxcbr0
	lxc.net.0.flags = up
	lxc.net.0.name = eth0
	lxc.apparmor.profile = generated
	lxc.apparmor.allow_nesting = 1
EOM
  echo 'USE_LXC_BRIDGE="true"' > /etc/default/lxc-net
}

config_snapd()
{
  $apt install snapd
  if test "X$SYSTYPE" = Xlxc ; then
    $apt install squashfuse fuse
  fi
}

config_lxd()
{
  config_snapd
  if ! test -d /var/snap/lxd ; then
    snap install lxd
    export PATH=$PATH:/snap/bin
    if test "X$1" = X ; then
      lxd init --auto --storage-backend=dir
    else
      lxd init --auto --storage-backend=btrfs --storage-pool="$1"
    fi
  fi
  CLOUDINIT="""user.user-data=#cloud-config
package_upgrade: true
packages:
  - openssh-server
timezone: Europe/Berlin
locale: de_DE.UTF-8
swap:
  filename: /swapfile
  size: "auto"
  maxsize: 2147483648
disable_root: false
users:
ssh_authorized_keys:
  - ssh-rsa xxxx user
"""
  lxc profile set default "$CLOUDINIT"
  lxc profile device add default root disk path=/ pool=default

  #lxc profile copy default vm
  lxc profile create vm
  lxc profile set vm limits.cpu 2
  lxc profile set vm limits.memory 2GB
  lxc profile set vm "$CLOUDINIT"
  lxc profile device add vm root disk path=/ pool=default
  lxc profile device set vm root size 20GB
  lxc profile device add vm eth0 bridged name=eth0 network=lxdbr0 type=nic
}

config_lxd_example()
{
  if false ; then
  lxc launch images:alpine/3.12/amd64 alpine
  lxc launch images:alpine/3.12/amd64 alpine-vm --vm -p vm
  lxc launch images:alpine/edge/amd64 alpine-edge
  lxc launch images:alpine/edge/amd64 alpine-edge-vm --vm -p vm
  fi

  lxc image list images: debian amd64
  lxc launch images:debian/10/cloud debian-10-cloud
  lxc launch images:debian/10/cloud debian-10-cloud-vm --vm -p vm
  lxc launch images:debian/11/cloud debian-11-cloud
  lxc launch images:debian/11/cloud debian-11-cloud-vm --vm -p vm
  lxc launch images:debian/sid/cloud debian-sid-cloud
  lxc launch images:debian/sid/cloud debian-sid-cloud-vm --vm -p vm

  lxc image list ubuntu: 20.04 amd64
  lxc launch images:ubuntu/focal/cloud ubuntu-focal-cloud
  lxc launch images:ubuntu/focal/cloud ubuntu-focal-cloud-vm --vm -p vm
  lxc launch ubuntu:20.04 ubuntu-focal
  lxc launch ubuntu:20.04 ubuntu-focal-vm --vm -p vm

  #lxc image copy ubuntu:20.04 local: --copy-aliases --auto-update

  #lxc exec debian-11-cloud -- /bin/bash
}

config_gdm()
{
  if test -f /etc/gdm3/greeter.dconf-defaults ; then
    # At login screen do not suspend, but only blank. For AC, not for battery:
    sed -i -e "s/^# sleep-inactive-ac-type='suspend'/sleep-inactive-ac-type='blank'/g" /etc/gdm3/greeter.dconf-defaults
    # For corporate setups, this could be useful:
    #sed -i -e "s/^# disable-user-list=/disable-user-list=/g" /etc/gdm3/greeter.dconf-defaults
  fi
}

automatic_login()
{
  sed -i -e "s/^#  AutomaticLoginEnable/AutomaticLoginEnable/g" /etc/gdm3/daemon.conf
  sed -i -e "s/^#  AutomaticLogin/AutomaticLogin/g" /etc/gdm3/daemon.conf
  sed -i -e "s/^AutomaticLogin = .*/AutomaticLogin = $1/g" /etc/gdm3/daemon.conf
}

if test "X$SYSTYPE" != Xlxc ; then
# squid http proxy:
if false ; then
  $apt install squid
  # Listen on all interfaces to provide proxy to the whole network:
  sed -i -e 's/^http_port .*/http_port 0.0.0.0:3128/g' /etc/squid/squid.conf
  cat > /etc/squid/conf.d/myproxy.conf <<-EOM
	http_access allow localnet
	# 2000 MB squid cache in two-level directory
	cache_dir diskd /var/spool/squid 2000 16 256
	# Default is 30 seconds and slows down reboots too much:
	shutdown_lifetime 10 seconds
EOM
fi

#config_lxc
fi

if test "X$SYSTYPE" = Xlxc ; then
  if test $DISTRO = debian -a $testing = 0 -a $unstable = 0 ; then
    systemctl disable binfmt-support.service
  fi
fi

#config_swapfile

# Firewall setup:
# - Port 80 and 443 are usually for a http/https server.
# - Port 22 is sshd.
# - Port 3128 should be added for a squid proxy.
#config_firewall "443 80 22" "443 80 22"

#config_lxd
#config_lxd_example

config_gdm
#automatic_login $NEWUSER

$apt clean
$apt update

# If this should again be used as a generic image, we remove
# ssh keys and write zeroes into unsued filesystem space:
if false && test $FIRSTRUN = 1 ; then
  dd if=/dev/zero of=/ZERO || rm -f /ZERO # zero unused filesystem
  rm -f /etc/ssh/ssh_host_*_key*
fi

