# Debian server image for ARM64

A Debian ARM64 image from their testing repository with mostly (text based)
basic server applications. This image should run fine on Raspberry Pi 3
Model B and B+ and also on Qemu.

Default upstream repository for this is at
https://github.com/laroche/arm-devel-infrastructure/tree/master/vmdb2-debian.

Debian has repositories for stable (which is now Debian 9), testing (which
should become the next stable release of Debian-10 later in 2019) and unstable.
Single even newer packages can be found on Debian experimental.

This is based mostly on http://git.liw.fi/vmdb2/ as included in Debian testing and newer.


## download a release image and prepare the image before booting

Download a binary image release from
https://github.com/laroche/arm-devel-infrastructure/releases.

Raspberry Pi 3 Model B and B+ should boot this image fine from a SD-card or
from a USB-stick. Here some information on how to write this image from a
Linux machine.

Normally the SD-card or USB-sticks are named devices like /dev/sdX. Make sure
you really find the correct device and not overwrite your harddisk or other
devices. Check the size of the device and check your syslog messages that show
up on connecting the device to your Linux machine.

The image contains an MS-DOS partition table with two partitions. The first
is a MS-DOS partition labeled debfirm with firmware files from Raspberry Pi
and a Linux kernel and initrd file. The second partition is an ext4 filesystem
labeled debroot with your complete Linux installation.
Since your device should have more room at the end of the image, you should
extend your second Linux partition to grow until the end of your device and
also create a swap partition and the end of your device. This can be done
with parted and it is easy to specify e.g. the last 2048MB of your device
via negative numbers like -2048. First the partition size is changed, then
the actual filesystem is grown.

```shell
wget https://github.com/laroche/arm-devel-infrastructure/releases/download/v20190323/debian-server-20190323.zip
unzip debian-server-20190323.zip
# Plug in your SD-card or USB-stick.
# Umount any automatically mounted existing partitions in /media/$USER/*.
sudo dd if=debian-server-20190323/debian-server-20190323.img of=/dev/sdX bs=4M oflag=dsync status=progress
sudo parted /dev/sdX
(parted) help
(parted) print
(parted) mkpart primary linux-swap -2048 -0
(parted) resizepart 2 -2048
(parted) quit
sudo mkswap -L DEBSWAP /dev/sdX3
sudo e2fsck -f /dev/sdX2
sudo resize2fs /dev/sdX2
```

The swap partition is already mentioned in /etc/fstab and you should check with free
if it is actually used ok.

If you reconnect your image device again to your Linux machine, the
filesystems are usually mounted automatically in /media/$USER/debroot
and /media/$USER/debfirm.
You can now change /etc/shadow for your root password and /etc/ssh/sshd_config
for your openssh server configuration.
Best is to create the file /root/.ssh/authorized_keys for remote login:

```shell
# Plug in your SD-card or USB-stick.
# Usually partitions are auto-mounted on /media/$USER/debfirm and /media/$USER/debroot.
edit /media/$USER/debfirm/config.txt          # firmware options
edit /media/$USER/debfirm/cmdline.txt         # Linux kernel boot parameters
edit /media/$USER/debroot/etc/shadow          # root pasword
edit /media/$USER/debroot/etc/ssh/sshd_config # openssh server options
mkdir -m 700 /media/$USER/debroot/root/.ssh   # authorized keys for remote login
cp ~/.ssh/id_rsa.pub /media/$USER/debroot/root/.ssh/authorized_keys
umount /media/$USER/debfirm
umount /media/$USER/debroot
```

Now remove the SD-card or the USB-stick from your Linux machine, insert it
into your Raspberry Pi and start it.


## building your own image

You should have Debian testing or newer installed to run these scripts
yourself:

```shell
sudo apt install vmdb2 dosfstools qemu qemu-user-static make #zip
git clone https://github.com/laroche/arm-devel-infrastructure
cd arm-devel-infrastructure/vmdb2-debian
edit debian.yaml
make
```

If you create a file "authorized_keys" this will get automatically added as
/root/.ssh/authorized_keys in the image.


## todo list

Things that could be improved in the future:
- grub configuration includes all local drives from my local PC,
  this should be limited to only the newly generated device.
  These additional entries are removed by running "update-grub" on the new system.
- grub installed into partition instead of full disk?
- For msdos partitioning the 'boot' flag is not set. (No real problem.)
- Check if the partioning is aligned properly.
- Easy switching to Debian unstable.
- Compile own kernel for armhf.
- Change name of own rpi3 kernel. Can then an image be made with
  generic arm64 efi boot which also has a rpi3 kernel?
  (EFI partition not the first one?)
- Automatically recompile new Debian kernels on each checkin into their
  git server 'salsa'.
- Provide a Debian repository with newer kernels instead of downloads.
  Also use github pages for this?
- Crosscompile the armhf/arm64 kernels on x86 for faster compile times.
- Install chromium directly from Google or are newer versions
  available for stable? Resolve this by using unstable for now.
- For documentation, check out https://github.com/jekyll/jekyll and hugo
  and improve appearance.
  https://help.github.com/en/articles/customizing-css-and-html-in-your-jekyll-theme


## link list

- https://wiki.debian.org/InstallingDebianOn/OdroidHC1

