Install and boot Debian rpi3 disk image
---------------------------------------

The release contains one disk image file (\*.img) with a ready to use generic Debian installation
for Raspberry Pi 3 Model B and B+ systems. You can install this rpi3 disk image onto a USB-disk/USB-stick
or a SD-card.
Disk images can be downloaded from the [release-page](https://github.com/laroche/arm-devel-infrastructure/releases).

To understand all details of this disk image, please look at the vmdb2
configuration file for this image: [debian-rpi3-arm64.yaml](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/debian-rpi3-arm64.yaml).
It contains a list of all software packages to include and a few configuration changes
done with shell scripting.

Please also look at the Debian projects
[https://salsa.debian.org/raspi-team/image-specs](https://salsa.debian.org/raspi-team/image-specs)
and [https://raspi.debian.net/](https://raspi.debian.net/).


Install disk size requirements
------------------------------

Very tiny text-based server systems are doable with a 4 GB disk. Recommended
are 16 GB or more for most systems. Let alone compiling the Debian kernel
package can use up to 55 GB of disk space, so devel environments should have
a minimum of 128 GB.

Here more detailed information on disk size usage: The provided raw/plain disk
image (\*.img) is 2 GB in size. This must be written to the beginning of a 2 GB
or greater install disk. If you want to install the gnome desktop, you need at
least 8 GB of disk size. And you normally add a swap partition that has the
same size as your RAM.


Disk layout
-----------

The release image (\*.img) contains one big hard disk image with a legacy 'msdos' partition table.
The first partition is a FAT32-formatted msdos partition with the firmware files and a kernel/initrd
which is later on mounted at `/boot/firmware`. The second partition contains a Linux ext4 filesystem
the generic Debian ARM64 installation.


Be careful before writing the disk image
----------------------------------------

Make sure your new USB-stick or hard disk is not mounted anywhere and you really want to delete
all your existing data on it and write this new generic Debian install image onto it.


How to use a Windows system to write the disk image onto a USB-Stick or SD-card
-------------------------------------------------------------------------------

TODO


How to use a Linux system to write the image onto a USB-Stick or a new hard disk
--------------------------------------------------------------------------------

```shell
# Download the current Debian rpi3 image:
wget -q https://github.com/laroche/arm-devel-infrastructure/releases/download/v20251129/debian-stable-rpi3-arm64-20251129.zip
# Unpack the zip archive to get the raw image *.img:
unzip debian-stable-rpi3-arm64-20251129.zip
# Make sure your install disk is not mounted:
#umount /media/$USER/XXX
# For USB check your devices:
#lsusb; lsblk
# Write the disk image to USB-disk or normal hard disk:
dd if=debian-stable-rpi3-arm64-20251129/debian-stable-amd64-20251129.img of=/dev/sdX
```


Bootup
------

Here is a summary on what you have on the first bootup:

- You have one hard disk. It has legacy 'msdos' partitioning and the first
  partition contains Raspberry Pi firmware on a FAT16 partition and the second
  partition contains an ext4 Linux filesystem with a generic Debian arm64/armhf
  installation.
- No root password is set. And no additional users are setup. Just login as 'root'.
- sshd is unchanged default configuration, so root login over network is not
  allowed. (Edit `/etc/ssh/sshd_config` to change this.)
- 'eth0' is setup as local network adapter and configured via dhcp. Change the file
  `/etc/network/interfaces.d/eth0` to change configuration. (Static IPs?)

Now log into this new system as root and execute the following commands to
add a swap partition with 4 GB size and DEBSWAP as label to the end of the
disk image and resize your current filesystem to the new size.
By using negative numbers for parted, they are relative to the end of the disk.
So the swap partition is created at the end of the disk image:

```shell
parted /dev/sda
  (parted) mkpart primary linux-swap -4096 -0
  (parted) resizepart 1
  (parted)     -4096
  (parted) quit
resize2fs /dev/sda1
mkswap -L DEBSWAP /dev/sda2
vim /etc/fstab
swapon -a
free
```

Here a few things you want todo on first login:

- Login as `root`.
- Change the root password: `passwd`
- Change sshd-server configuration: `vim /etc/ssh/sshd_config`
- Change eth0 network configuration: `vim /etc/network/interfaces.d/eth0`
- Configure a wireless adapter.
- Update your software: `apt-get update; apt-get dist-upgrade; apt-get autoremove`
- How to change from stable to testing/unstable.
- Install an RT-kernel.

