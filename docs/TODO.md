## todo list

Things that could be improved in the future:


partitioning and grub
---------------------

- Generated grub config shows too many entries from local system.
  Fixed by first update-grub invocation on an installed system.
   - Check creating new images within lxc resolves this.
- grub installed into partition instead of full disk?
- Check if the partitioning is aligned properly.
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
- For lxc guests with Debian testing systemd-logind.service fails. Create upstream report.
- If not connected to the Internet, ntpd logs often about failed DNS resolver. Rate limit logging.
- How to disable suspend on a laptop booting into GUI login screen. gdm?
- Use the new sshd .d config dirs for all config changes if available. Also environment.d.
- Should we run "apt-get clean" periodically?
- Should we change sources.list for Debian testing from "testing" to "bullseye"?


other
-----

- For documentation, check out [jekyll](https://github.com/jekyll/jekyll) and [hugo](https://gohugo.io/)
  and improve appearance.
  [https://help.github.com/en/articles/customizing-css-and-html-in-your-jekyll-theme](https://help.github.com/en/articles/customizing-css-and-html-in-your-jekyll-theme)
- Disable unattended apt package updates during tests.
- Can we upload new release files automatically to github?
- Test RPi3 images with wifi, desktop, etc. Test new RPi4.

