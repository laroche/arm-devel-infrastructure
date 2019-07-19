Install and boot Debian Amd64 disk image
----------------------------------------

Naming: Debian uses 'amd64' to refer to 64bit x86 systems, sometimes also called x86_64.

The release contains one disk image file (*.img) with a ready to use generic Debian installation
for amd64 systems. You can install this amd64 disk image onto a USB-disk, a normal harddisk or a virtual guest system.


Install disk size requirements
------------------------------

Very small systems are doable with a 4GB disk. Recommended are 16GB or more. Let alone
compiling the Debian kernel package can use up to 55GB of disk space, so devel environments
should have minimum 128GB.

Here more detailed information on disk size usage:
The provided raw/plain disk image (*.img) is 2GB in size. This must be written to the beginning
of a 2GB or greater install disk. As you want to install additional software
and also create a swap partition with the size of your RAM, you should need at least 4GB for a small
text-based server system.
If you want to install the gnome desktop, you need at least 8GB of disk size. And you normally add a swap
partition that has the same size as your RAM.


Disk layout
-----------

The release image (*.img) contains one big harddisk image with a legacy 'msdos' partition table
and one partition with an ext4 filesystem with the generic Debian installation.


Be careful before writing the disk image
----------------------------------------

Make sure your new USB-stick or harddisk is not mounted anywhere and you really want to delete
all your existing data on it and write this new generic Debian install image onto it.


How to use a Windows system to write the disk image onto a USB-Stick or a new harddisk
--------------------------------------------------------------------------------------

TODO


How to use a Linux system to write the image onto a USB-Stick or a new harddisk
-------------------------------------------------------------------------------

  # Download the current Debian Amd64 image:
  wget https://github.com/laroche/arm-devel-infrastructure/releases/download/v20190628/debian-buster-amd64-core-20190628.zip
  # Unpack the zip archive to get the raw image *.img:
  unzip debian-buster-amd64-core-20190628.zip
  # Make sure your install disk is not mounted:
  #umount /media/$USER/XXX
  # For USB check your devices:
  #lsusb
  # Write the disk image to USB-disk or normal harddisk:
  dd if=debian-buster-amd64-core-20190628/debian-buster-amd64-core-20190628.img of=/dev/sdX

On a Linux system, how to create a Linux KVM guest system
---------------------------------------------------------

This assumes a Debian or Ubuntu host machine (on which a virtualized Linux guest system is created).
Other Linux distributions should be similar.

This is using the Linux KVM hypervisor. Make sure you have qemu-img, virsh, virt-inst, virt-manager
installed.

    # Download the current Debian Amd64 image:
    wget https://github.com/laroche/arm-devel-infrastructure/releases/download/v20190628/debian-buster-amd64-core-20190628.zip
    unzip debian-buster-amd64-core-20190628.zip
    # Convert the plain/raw image file into qcow2 format:
    qemu-img convert -O qcow2 debian-buster-amd64-core-20190628/debian-buster-amd64-core-20190628.img debian.qcow2
    # Remove the release/download to save disk space:
    rm -fr debian-buster-amd64-core-20190628
    # Add additional space to the image:
    qemu-img resize debian.qcow2 +80G
    # Create a snapshot of the current state:
    qemu-img snapshot -c start debian.qcow2
    # List all available snapshots:
    qemu-img snapshot -l debian.qcow2
    # Start a new guest system with this image:
    virt-install --name debian01 --memory 4096 --cpu host --vcpus 4 --boot hd --disk debian.qcow2


On a Linux system, how to install on an existing harddisk into a new partition
------------------------------------------------------------------------------

TODO



Bootup
------

Root password, network setup for 'eth0', disk partitions.

How to configure local network or wireless.


Now log into this new system as root and execute the following commands to
add a swap partition with 4GB size to the end of the disk image and resize
your current filesystem to the new size (By using negative numbers, the swap
partition is created at the end of the disk image.):

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

Here some more commands for virtualization:

    sudo apt install virtinst virt-manager
    virsh list --all
    virsh start debian01
    virt-viewer debian01
    virsh shutdown debian01
    virsh destroy debian01
    virsh undefine debian01

Root passwords for amd64, armhf/arm64.
Software-update: apt update; apt dist-upgrade
How to change from stable to unstable.
Installing the RT-kernel.

