locally compile current Qemu
----------------------------

Most Linux distributions do not update qemu to current versions, but
you can compile the current qemu release yourself. A good target for
installation is `/opt/qemu` (Check [qemu download](https://www.qemu.org/download/#source) as reference.):

    ```shell
    wget https://download.qemu.org/qemu-4.1.0-rc1.tar.xz
    tar xJf qemu-4.1.0-rc1.tar.xz
    cd qemu-4.1.0-rc1
    ./configure --prefix=/opt/qemu
    make -j 8
    sudo make install
    ```

