Use `qemu`_ to create arm32 or arm64 guest images of `Debian`_. With either their
current "stable", "testing" or "unstable" distributions.



Example usage::

  ./debian.sh 32 stable   2222
  ./debian.sh 32 testing  2222
  ./debian.sh 32 unstable 2222
  ./debian.sh 64 stable   2222
  ./debian.sh 64 testing  2222
  ./debian.sh 64 unstable 2222

On the first invocation the corresponding ISO install image
is downloaded and a new hard disk image is created. With subsequent
invocations, the existing harddisk image is started.

.. _qemu: https://www.qemu.org/
.. _Debian: https://www.debian.org/
