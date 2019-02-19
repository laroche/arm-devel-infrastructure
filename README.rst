arm-devel-infrastructure
------------------------

some support scripts for arm32 and arm64 development environments

Official repository is `https://github.com/laroche/arm-devel-infrastructure`_




locally compile current Qemu
----------------------------

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
.. _https://github.com/laroche/arm-devel-infrastructure: https://github.com/laroche/arm-devel-infrastructure
