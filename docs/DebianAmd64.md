Install and boot Debian Amd64 disk image
----------------------------------------

Naming: Debian uses 'amd64' to refer to 64bit x86 systems, sometimes also called x86_64.

The release contains one disk image file (\*.img) with a ready to use generic Debian installation
for amd64 systems. You can install this amd64 disk image onto a USB-disk, a normal hard disk or a virtual guest system.
Disk images can be downloaded from the [release-page](https://github.com/laroche/arm-devel-infrastructure/releases).

To understand all details of this disk image, please look at the vmdb2
configuration file for this image: [debian-amd64.yaml](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/debian-amd64.yaml).
It contains a list of all software packages to include and a few configuration changes
done with shell scripting.


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

The release image (\*.img) contains one big hard disk image with a legacy 'msdos' partition table
and one partition with an ext4 filesystem with the generic Debian installation.


Be careful before writing the disk image
----------------------------------------

Make sure your new USB-stick or hard disk is not mounted anywhere and you really want to delete
all your existing data on it and write this new generic Debian install image onto it.


How to use a Windows system to write the disk image onto a USB-Stick or a new hard disk
---------------------------------------------------------------------------------------

TODO


How to use a Linux system to write the image onto a USB-Stick or a new hard disk
--------------------------------------------------------------------------------

```shell
# Download the current Debian Amd64 image:
wget -q https://github.com/laroche/arm-devel-infrastructure/releases/download/v20240728/debian-stable-amd64-20240728.zip
# Unpack the zip archive to get the raw image *.img:
unzip debian-stable-amd64-20240728.zip
# Make sure your install disk is not mounted:
#umount /media/$USER/XXX
# For USB check your devices:
#lsusb; lsblk
# Write the disk image to USB-disk or normal hard disk:
dd if=debian-stable-amd64-20240728/debian-stable-amd64-20240728.img of=/dev/sdX
```


On a Linux system, how to create a Linux KVM guest system
---------------------------------------------------------

This assumes a Debian or Ubuntu host machine (on which a virtualized Linux guest system is created).
Other Linux distributions should be similar.

This is using the Linux KVM hypervisor. Make sure you have qemu-img, virsh, virt-inst, virt-manager
installed.

Use the following shell script to download the current release and start a new guest system:
[install.sh](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/install.sh).
You can adjust the RAM size and number of CPUs in the script. It can also copy a modified setup.sh
script into the image and e.g. the newest kernel. This allows automated adapted installs.

TODO: Use virtio for the hard disk?

If you are new to virtualization, please look at the following commands and how they work:

```shell
# Install the needed software for Debian or Ubuntu systems:
sudo apt-get install virtinst virt-manager
# List all available guest/virtualized systems:
virsh list --all
# start/boot a guest system:
virsh start debian01
# Look at the console/screen output of a guest system:
virt-viewer debian01
# Regular shutdown of a guest system:
virsh shutdown debian01
# Hard shutdown of a guest system:
virsh destroy debian01
# Delete a guest system completely. Sometimes you need to remove the hard disk then manually:
virsh undefine debian01
# qemu-img to handel disk images and convert them.
```

virt-viewer can sometimes hang. Just restarting it helps and you should try
this before restarting a guest system.


How to use other virtualization programs to start a guest system
----------------------------------------------------------------

TODO document VirtualBox on Linux/Windows


On a Linux system, how to install on an existing hard disk into a new partition
-------------------------------------------------------------------------------

TODO


Bootup
------

Here is a summary on what you have on the first bootup:

- You have one hard disk. It has legacy 'msdos' partitioning and the first
  partition contains an ext4 Linux filesystem with a generic Debian Amd64
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

