How to compile your own kernel from current Debian git sources
--------------------------------------------------------------

The source code for the Debian Linux kernel is maintained within an gitlab server [here](https://salsa.debian.org/kernel-team/linux/commits/master).
The [master](https://salsa.debian.org/kernel-team/linux/commits/master) branch currently is based on linux-5.2.y,
the [sid](https://salsa.debian.org/kernel-team/linux/commits/sid) branch is based on linux-4.19.37 (Debian 10 release kernel).

You can checkout these branches and recompile locally a current Debian kernel with
these scripts: [kernel.sh](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/kernel.sh)
and [kernel5.sh](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/kernel.sh).


Blocking kernel updates with dpkg
---------------------------------

If you compile your own kernel images and don't want official kernels to be
installed automatically, you can change the dpkg status from 'install' to 'hold':

```shell
dpkg -l | grep linux-image
echo linux-image-amd64 hold | sudo dpkg --set-selections
dpkg -l linux-image-amd64
echo linux-image-amd64 install | sudo dpkg --set-selections
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
- [https://wiki.debian.org/KernelFAQ](https://wiki.debian.org/KernelFAQ)
- [https://kernel-team.pages.debian.net/kernel-handbook/ch-common-tasks.html#s-common-official](https://kernel-team.pages.debian.net/kernel-handbook/ch-common-tasks.html#s-common-official)
- [https://wiki.debian.org/HowToUpgradeKernel](https://wiki.debian.org/HowToUpgradeKernel)
- [https://wiki.debian.org/DebianExperimental](https://wiki.debian.org/DebianExperimental)
- [https://wiki.debian.org/HowToCrossBuildAnOfficialDebianKernelPackage](https://wiki.debian.org/HowToCrossBuildAnOfficialDebianKernelPackage)

