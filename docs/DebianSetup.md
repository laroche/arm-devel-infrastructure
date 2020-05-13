Scripting additional software installations and system configuration
--------------------------------------------------------------------

Once you have booted a generic Debian image, you probably want to install
additional software and configure your system for convenient use.

Please check the following script and adapt it for your own use:
[setup.sh](https://github.com/laroche/arm-devel-infrastructure/blob/master/vmdb2-debian/setup.sh).
This is also copied onto the disk images as `/root/setup.sh`.

Login as `root` and just start setup for all software installs and config modifications:
```shell
./setup.sh
```

If you enable a GUI install, you should start the X11 server and run a few modifications
for the GUI of the user. Logout as `root` and login as `max` (or whatever your normal account
name is):

```shell
startx
# Now open a terminal window:
sudo cp /root/setup.sh .
bash setup.sh
rm -f setup.sh
```

