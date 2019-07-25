Debian Linux Kernel Handbook
----------------------------

Please read the reference [Debian Linux Kernel Handbook](https://kernel-team.pages.debian.net/kernel-handbook/index.html).


How to compile your own kernel from current Debian git sources
--------------------------------------------------------------

The source code for the Debian Linux kernel is maintained within the [salsa gitlab server](https://salsa.debian.org/kernel-team/linux/commits/master).
The [master](https://salsa.debian.org/kernel-team/linux/commits/master) branch currently is based on linux-5.2.y,
the [sid](https://salsa.debian.org/kernel-team/linux/commits/sid) branch is based on linux-4.19.37 (Debian 10 release kernel).

You can checkout these branches and recompile locally a current Debian kernel with
these scripts: [kernel.sh](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/kernel.sh)
and [kernel5.sh](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/kernel.sh).

You can also cross-compile armhf and arm64 kernels on amd64, also adding all raspberry-pi patches is fully scripted:
```shell
# cross-compile a generic 5.2.y armhf kernel:
./kernel5.sh armhf
# cross-compile a generic 5.2.y arm64 kernel:
./kernel5.sh arm64
# cross-compile a 5.2.y armhf kernel with all raspbian-pi patches included:
./kernel5.sh rpi-armhf
# cross-compile a 5.2.y arm64 kernel with all raspbian-pi patches included:
./kernel5.sh rpi-armhf
```

You can download already compiled kernels from the [release page](https://github.com/laroche/arm-devel-infrastructure/releases).


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


How to install a kernel from the experimental distribution
----------------------------------------------------------

Sometimes newer kernels are pushed to the experimentl distribution, so you might
want to check there for a newer Debian kernel. This is probably best done if
your local system is Debian testing or Debian unstable:

```shell
if ! test -f /etc/apt/sources.list.d/experimental.list ; then
  echo "deb http://deb.debian.org/debian/ experimental main contrib non-free" > /etc/apt/sources.list.d/experimental.list
  echo "deb-src http://deb.debian.org/debian/ experimental main contrib non-free" >> /etc/apt/sources.list.d/experimental.list
fi
apt update
apt-cache search linux-image
apt install linux-image-5.0.0-trunk-arm64
```


Link List
---------
- [https://tracker.debian.org/pkg/linux](https://tracker.debian.org/pkg/linux)
- [https://lists.debian.org/debian-kernel/](https://lists.debian.org/debian-kernel/)
- [https://wiki.debian.org/KernelFAQ](https://wiki.debian.org/KernelFAQ)
- [https://wiki.debian.org/HowToUpgradeKernel](https://wiki.debian.org/HowToUpgradeKernel)
- [https://wiki.debian.org/DebianExperimental](https://wiki.debian.org/DebianExperimental)
- [https://wiki.debian.org/HowToCrossBuildAnOfficialDebianKernelPackage](https://wiki.debian.org/HowToCrossBuildAnOfficialDebianKernelPackage)

