Creating your own disk images
-----------------------------

Best should be to add as many as possible changes into `setup.sh` and
keep the disk images generic.

You should have Debian 10 or newer installed to run these scripts
yourself.

```shell
sudo apt install vmdb2 dosfstools qemu qemu-user-static make #zip
git clone https://github.com/laroche/arm-devel-infrastructure
cd arm-devel-infrastructure/vmdb2-debian
edit debian.yaml
make -j 8
```

You can also just create individual images like:

```shell
make debian-amd64.img
```

If you create a file `authorized_keys` this will get automatically added as
`/root/.ssh/authorized_keys` in the image.

