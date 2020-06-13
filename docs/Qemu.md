locally compile current qemu
----------------------------

Most Linux distributions do not update [qemu](https://www.qemu.org/) to
current versions, but you can compile the current qemu release yourself.
A good target for installation is `/opt/qemu`. (Check
[qemu download](https://www.qemu.org/download/#source) as reference.)

As of mai 2020, Debian testing/unstable contains qemu-5.0.0:
[https://tracker.debian.org/pkg/qemu](https://tracker.debian.org/pkg/qemu).

Download, compile and install a current qemu to `/opt/qemu`:
```shell
sudo apt-get install pkg-config libglib2.0-dev libpixman-1-dev
wget -q https://download.qemu.org/qemu-5.0.0.tar.xz
tar xJf qemu-5.0.0.tar.xz
cd qemu-5.0.0
./configure --prefix=/opt/qemu
make -j 8
sudo make install
```

