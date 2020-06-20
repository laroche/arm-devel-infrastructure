Debian lxc setup
----------------


lxc (server) install
--------------------

If you want to install lxc software and configure it, you can
use setup.sh to configure it. The basic setup on Debian is like this:

```shell
apt-get install lxc
lxc-checkconfig
cat > /etc/lxc/default.conf <<EOM
#lxc.net.0.type = empty
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.net.0.name = eth0
lxc.apparmor.profile = generated
lxc.apparmor.allow_nesting = 0
EOM
echo 'USE_LXC_BRIDGE="true"' > /etc/default/lxc-net
```

For lxc networking to come up, easiest is to just do a full reboot.
Or you can use "/usr/libexec/lxc/lxc-net start" and verify with
"brctrl show".


lxc commands
------------

Here some of the lxc commands you should learn:

```shell
# Create a new container:
lxc-create -n debian01 -t debian -- -r sid --enable-non-free
# Start the new container:
lxc-start -n debian01
# Information on a container:
lxc-info -n debian01
# Check the console output:
lxc-console -n debian01
# Open a shell within the container:
lxc-attach -n debian01
# List of all containers:
lxc-ls --fancy
# Stop a container from running:
lxc-stop -n debian01
# Delete a container from disk:
lxc-destroy -n debian01
```


lxc guest installs
------------------

To start a new Debian guest and configure it with "setup.sh", please use the
following commands as root:

```shell
# 'sid' is Debian testing, you can also use 'buster' for Debian stable or 'unstable':
lxc-create -n debian01 -t debian -- -r sid --enable-non-free --auth-key ~/.ssh/id_rsa.pub
# Default is to install into a new directory. If you want to use a new lvm disk, you
# can add the options e.g.: "--bdev lvm --lvname lxc-debian01 --vgname debvg --fssize 25G"
lxc-start -n debian01
lxc-ls --fancy
# Get list of IPs of the containers:
IP="$(sudo lxc-ls --fancy | tail -n +2 | awk '{ print $5 }')"
for i in $IP ; do
  ssh -T root@$i "bash -s" < setup.sh
done
# lxc-stop -n debian01
# lxc-destroy -n debian01 -f -s
```

I use the following convenient wrapper script "lxc-setup.sh" to start/configure/stop my lxc
guest systems:

```shell
#!/bin/bash

if test "X$1" = Xcreate ; then
  for i in 01 02 03 ; do
     #sudo lxc-create -n debian$i -t debian -- -r buster --enable-non-free --auth-key ~/.ssh/id_rsa.pub
     sudo lxc-create -n debian$i --bdev lvm --lvname lxc-debian$i --vgname debvg --fssize 25G -t debian -- -r sid --enable-non-free --auth-key ~/.ssh/id_rsa.pub
     #sudo lxc-create -n debian$i -t debian -- -r sid --enable-non-free --auth-key ~/.ssh/id_rsa.pub
     #sudo lxc-create -n debian$i -t debian -- -r unstable --enable-non-free --auth-key ~/.ssh/id_rsa.pub
     sudo lxc-start -n debian$i
  done
elif test "X$1" = Xdestroy ; then
  # Get list of container names:
  CONTAINER="$(sudo lxc-ls)"
  for i in $CONTAINER ; do
    sudo lxc-destroy -n $i -f -s
  done
elif test "X$1" = Xconfig -o "X$1" = Xcheck ; then
  # Get list of IPs of the containers:
  IP="$(sudo lxc-ls --fancy | tail -n +2 | awk '{ print $5 }')"
  #IP="10.0.3.126"
  #IP="$IP knorke2"
  for i in $IP ; do
    echo -e "\n\n\n--------------------------------------------------------------------------------------------"
    echo "Run setup on $i:"
    if test "X$i" = "X-" ; then
      echo "No IP found, skipping."
      continue
    fi
    #echo apt-get clean | ssh -T root@$i "bash -s"
    #sudo lxc-attach -n $i -- bash -c "apt clean; apt update; apt dist-upgrade"
    if test "X$1" = Xcheck ; then
      ssh -T root@$i "bash -s" check < setup.sh
    else
      ssh -T root@$i "bash -s" < setup.sh
    fi
  done
elif test "X$1" = Xstart -o "X$1" = Xstop ; then
  # Get list of container names:
  CONTAINER="$(sudo lxc-ls)"
  for i in $CONTAINER ; do
    sudo lxc-$1 -n $i
  done
elif test "X$1" = Xls ; then
  sudo lxc-ls --fancy
fi
exit 0
```

