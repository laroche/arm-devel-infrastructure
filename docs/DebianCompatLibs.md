32bit compat libs for arm64
---------------------------

If you are on a 64bit system (kernel and user level) like e.g. arm64,
you can add armhf as secondary arch. This is written into '/var/lib/dpkg/arch'.

Install 32bit compat libs on arm64 Debian:

```shell
if ! test -f /var/lib/dpkg/arch ; then
  dpkg --add-architecture armhf
fi
apt update
apt install libc6:armhf libstdc++6:armhf
```

With older installations you might need this symlink:

```shell
ln -s arm-linux-gnueabihf/ld-2.23.so /lib/ld-linux.so.3
```

