Creating your own disk images
-----------------------------

Best should be to add as many as possible changes into `setup.sh` and
keep the disk images generic.

You should have Debian 12 or newer installed to run these scripts
yourself.

```shell
sudo apt-get install vmdb2 dosfstools qemu qemu-user-static make #zip
git clone https://github.com/laroche/arm-devel-infrastructure
cd arm-devel-infrastructure/vmdb2-debian
edit debian-12-amd64.yaml
make
```

You can also just create individual images like:

```shell
make debian-12-amd64.img
```

