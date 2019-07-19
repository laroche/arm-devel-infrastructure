arm-devel-infrastructure
------------------------

Provide generic [Debian Linux](https://www.debian.org/) disk images for
PCs(amd64) and ARM devices. These can be used for development environments
or server installs and are based on [vmdb2](https://vmdb2.liw.fi/) plus
automatic scripts for configuration.
Also include useful links to some key Linux development projects (for arm).

Arm disk images are prepared for generic armhf or arm64 devices,
there are extra images for [Raspberry-PI](https://www.raspberrypi.org/).


Official github repository is https://github.com/laroche/arm-devel-infrastructure

Documentation is available at https://laroche.github.io/arm-devel-infrastructure



locally compile current Qemu
----------------------------

Most Linux distributions do not update qemu to current versions, but
you can compile the current qemu release yourself. A good target for
installation is `/opt/qemu` (Check [qemu download](https://www.qemu.org/download/#source) as reference.):

  wget https://download.qemu.org/qemu-4.0.0.tar.xz
  tar xJf qemu-4.0.0.tar.xz
  cd qemu-4.0.0
  ./configure --prefix=/opt/qemu
  make
  sudo make install

