---
title: todo list
---


## todo list

Things that could be improved in the future:


partitioning and grub
---------------------

- For amd64 change from msdos partitioning to gpt. Test if this works with
  some real hardware as well as virsh/qemu.
- grub installed into partition instead of full disk?
- grub keyboard layout is "us", change this to "de".
- parted: check if "-4096"-bug can be fixed upstream. Is workaround possible?
  This is not needed with lvm setups, so less important.


docu
----

- Mention "de" specific configurations in docu.


kernel
------

- Change name of own rpi3 kernel.
- Automatically recompile new Debian kernels on each checkin into the Debian
  git server 'salsa'.
- Provide a Debian repository with newer kernels instead of downloads.
  Use github pages for this?
- How to extract rpi patches for older kernel revisions?


installed apps
--------------

- maybe install chrony instead of ntp, fake-hwclock, rng-tools instead of haveged
- sysstat
- With a minimal system "systemctl" shows errors with "console-setup.service": [Debian bug 846256](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=846256)
- Check the difference between a minimal lxc system and vmdb2. Why do we need to add less and apt-utils for lxc?
- For lxc guests with Debian testing/unstable systemd-logind.service fails. Create upstream report.
- If not connected to the Internet, ntpd logs often about failed DNS resolver. Rate limit logging.
- Use the new sshd .d config dirs for all config changes if available. Also environment.d.
- Should we run "apt-get clean" periodically?
- unattended updates are per default not enabled for addon repositories, so you need
  periodic and manual "apt dist-upgrade". Should this be changed?
- "apt-get update" does not give an error if repos are not updated, so script error checking is limited.
  Can apt-get get an extra option for this?
- setup.sh proposals:
   - Should we change sources.list for Debian testing from "testing" to "bookworm"?
   - Maybe support lxc for firewall rules.
   - config_firewall: add extra option for udp ports?


other
-----

- For documentation, check out [jekyll](https://github.com/jekyll/jekyll) and [hugo](https://gohugo.io/)
  and improve appearance.
  [https://help.github.com/en/articles/customizing-css-and-html-in-your-jekyll-theme](https://help.github.com/en/articles/customizing-css-and-html-in-your-jekyll-theme)
- Disable unattended apt package updates during tests.
- Can we upload new release files automatically to github?
- Test RPi3 images with wifi, desktop, etc. Test with RPi4.

