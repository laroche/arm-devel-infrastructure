Debian Linux Kernel Handbook
----------------------------

Please read the reference [Debian Linux Kernel Handbook](https://kernel-team.pages.debian.net/kernel-handbook/index.html).


How to compile your own kernel from current Debian git sources
--------------------------------------------------------------

The source code for the Debian Linux kernel is maintained within the [salsa gitlab server](https://salsa.debian.org/kernel-team/linux/commits/master).
The [master](https://salsa.debian.org/kernel-team/linux/commits/master) branch currently is based on linux-6.9.y,
the [sid](https://salsa.debian.org/kernel-team/linux/commits/sid) branch is based on linux-6.9.y,
the [bookworm](https://salsa.debian.org/kernel-team/linux/commits/bookworm) branch is based on linux-6.1.y and
the [bullseye](https://salsa.debian.org/kernel-team/linux/commits/buster) branch is based on linux-5.10.y.

You can checkout these branches and recompile locally a current Debian kernel with
this script: [kernel.sh](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/kernel.sh).
This uses about 6 GB of disk space.

You can also cross-compile armhf and arm64 kernels on amd64, also adding all raspberry-pi patches is fully scripted:
```shell
# cross-compile a generic armhf kernel:
./kernel.sh armhf
# cross-compile a generic arm64 kernel:
./kernel.sh arm64
# cross-compile an armhf kernel with all raspbian-pi patches included:
./kernel.sh rpi-armhf
# cross-compile an arm64 kernel with all raspbian-pi patches included:
./kernel.sh rpi-arm64
```

You can download already compiled kernels from the [release page](https://github.com/laroche/arm-devel-infrastructure/releases).

This mailinglist discusses rpi support for the upstream/mainline kernel:
[http://lists.infradead.org/pipermail/linux-rpi-kernel/](http://lists.infradead.org/pipermail/linux-rpi-kernel/)

German Heise to current Raspi-4 Support:
[https://www.heise.de/ct/artikel/Linux-5-5-Raspi-4-Unterstuetzung-reift-32-Bit-x86-Support-verkuemmert-4605827.html](https://www.heise.de/ct/artikel/Linux-5-5-Raspi-4-Unterstuetzung-reift-32-Bit-x86-Support-verkuemmert-4605827.html)

UEFI firmware for Raspberry Pi 4B: [https://rpi4-uefi.dev/](https://rpi4-uefi.dev/)


archive of older debian packages
--------------------------------

If you want to download older debian software packages, please look at <https://snapshot.debian.org/>.


openocd and JTAG
----------------

openocd and JTAG setup for RaspberryPi 3B: [https://metebalci.com/blog/bare-metal-raspberry-pi-3b-jtag/](https://metebalci.com/blog/bare-metal-raspberry-pi-3b-jtag/)


Blocking kernel updates with dpkg
---------------------------------

If you compile your own kernel images and don't want official kernels to be
installed automatically, you can change the dpkg status from 'install' to 'hold':

```shell
# list all installed linux-image deb packages:
dpkg -l | grep linux-image
# change one specific package to 'hold'
echo linux-image-amd64 hold | sudo dpkg --set-selections
# list current status of the package:
dpkg -l linux-image-amd64
# reset status to normal 'install':
echo linux-image-amd64 install | sudo dpkg --set-selections
# list current status of the package:
dpkg -l linux-image-amd64
```

Or you can use apt-mark directly:

```shell
apt-mark hold linux-image-amd64
```


Linux Test Project LTP
----------------------
- [http://linux-test-project.github.io/](http://linux-test-project.github.io/)
  - [https://github.com/linux-test-project/ltp](https://github.com/linux-test-project/ltp)
  - [http://lists.linux.it/pipermail/ltp/](http://lists.linux.it/pipermail/ltp/)

Compile and install ltp into `/opt/ltp`:

```shell
sudo apt-get install build-essential autoconf libtool libtool-bin bison flex git libacl1-dev libssl-dev
sudo apt-get install quotatool
git clone --depth 1 https://github.com/linux-test-project/ltp
pushd ltp
make autotools
./configure
make -j 8
sudo make install
popd
# Execute the tests:
sudo LANG=en_US.UTF-8 /opt/ltp/runltp -Q
```

Note: Please keep IPv6 enabled for LTP tests.

If your host is not properly configured within DNS and you want to pass
IP lookup tests, you can add your host to /etc/hosts:
```shell
echo -e "127.0.0.2\t$HOSTNAME" >> /etc/hosts
echo -e "::2\t\t$HOSTNAME" >> /etc/hosts
```


Fuego Test System
-----------------
[Fuego](http://fuegotest.org/) packages Jenkins into a Docker container to run LTP on embedded boards.
See also:

- [https://bitbucket.org/fuegotest/fuego/src/master/](https://bitbucket.org/fuegotest/fuego/src/master/)
- [https://bitbucket.org/fuegotest/fuego-core/src/master/](https://bitbucket.org/fuegotest/fuego-core/src/master/)


Syzkaller
---------
- [https://github.com/google/syzkaller](https://github.com/google/syzkaller)
- [https://syzkaller.appspot.com/](https://syzkaller.appspot.com/)
- [https://groups.google.com/forum/#!forum/syzkaller](https://groups.google.com/forum/#!forum/syzkaller)
- [https://google.github.io/oss-fuzz/](https://google.github.io/oss-fuzz/)

To start syzkaller locally for arm32 and arm64, you can use the script
[syzkaller.sh](https://github.com/laroche/arm-devel-infrastructure/tree/master/syzkaller/syzkaller.sh).
If you build both the 32bit and 64bit tests, this uses about 20 GB of disk space.


Automated Linux Kernel Testing
------------------------------
- [https://github.com/metan-ucw/runltp-ng](https://github.com/metan-ucw/runltp-ng)
- [https://kernelci.org/](https://kernelci.org/)
- [https://lwn.net/Articles/777421/](https://lwn.net/Articles/777421/)
- [https://lwn.net/Articles/514278/](https://lwn.net/Articles/514278/)
- [https://01.org/lkp/documentation/0-day-brief-introduction](https://01.org/lkp/documentation/0-day-brief-introduction)
- [https://01.org/lkp/documentation/0-day-test-service](https://01.org/lkp/documentation/0-day-test-service)
- [https://github.com/ruscur/snowpatch](https://github.com/ruscur/snowpatch)


Link List
---------
- [https://tracker.debian.org/pkg/linux](https://tracker.debian.org/pkg/linux)
- [https://lists.debian.org/debian-kernel/](https://lists.debian.org/debian-kernel/)
- [https://wiki.debian.org/KernelFAQ](https://wiki.debian.org/KernelFAQ)
- [https://wiki.debian.org/HowToUpgradeKernel](https://wiki.debian.org/HowToUpgradeKernel)
- [https://wiki.debian.org/DebianExperimental](https://wiki.debian.org/DebianExperimental)
- [https://wiki.debian.org/HowToCrossBuildAnOfficialDebianKernelPackage](https://wiki.debian.org/HowToCrossBuildAnOfficialDebianKernelPackage)

