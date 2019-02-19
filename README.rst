some support scripts for an arm32 or arm64 development environment




locally compile current Qemu
============================

Most Linux distributions do not update qemu to current versions, but
you can compile the current qemu release yourself. A good target for
installation is `/opt/qemu` (Check `qemu download`_ as reference.)::

  wget https://download.qemu.org/qemu-3.1.0.tar.xz
  tar xJf qemu-3.1.0.tar.xz
  cd qemu-3.1.0
  ./configure --prefix=/opt/qemu
  make
  sudo make install


.. _qemu download: https://www.qemu.org/download/#source
