locally compile current qemu
----------------------------

Most Linux distributions do not update [qemu](https://www.qemu.org/) to
current versions, but you can compile the current qemu release yourself.
A good target for installation is `/opt/qemu`. (Check
[qemu download](https://www.qemu.org/download/#source) as reference.)

As of september 2019, Debian unstable contains a current qemu-4.1.0.

Download, compile and install a current qemu to `/opt/qemu`:
```shell
sudo apt install pkg-config libglib2.0-dev libpixman-1-dev
wget -q https://download.qemu.org/qemu-4.1.0.tar.xz
tar xJf qemu-4.1.0.tar.xz
cd qemu-4.1.0
./configure --prefix=/opt/qemu
make -j 8
sudo make install
```

