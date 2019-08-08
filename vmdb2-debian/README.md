# Debian server image for ARM64

Normally the SD-card or USB-sticks are named devices like /dev/sdX. Make sure
you really find the correct device and not overwrite your hard disk or other
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
wget -q https://github.com/laroche/arm-devel-infrastructure/releases/download/v20190323/debian-server-20190323.zip
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


## link list

- https://github.com/UMRnInside/RPi-arm64
- https://github.com/openfans-community-offical/Debian-Pi-Aarch64
- https://wiki.debian.org/InstallingDebianOn/OdroidHC1
- https://pete.akeo.ie/2019/07/installing-debian-arm64-on-raspberry-pi.html
- https://www.armbian.com/

