## todo list

Things that could be improved in the future:


partitioning and grub
---------------------

- Generated grub config shows too many entries from local system.
  Fixed by first update-grub invocation on an installed system.
- grub installed into partition instead of full disk?
- Check if the partitioning is aligned properly.
- grub keyboard layout is us, change this to de.
- parted: check if "-4096"-bug can be fixed upstream. Is workaround possible?


docu
----

- Mention de specific configurations in docu.


kernel
------

- Change name of own rpi3 kernel.
- Automatically recompile new Debian kernels on each checkin into their
  git server 'salsa'.
- Provide a Debian repository with newer kernels instead of downloads.
  Use github pages for this?
- How to extract rpi patches for older kernel revisions?


other
-----

- For documentation, check out [https://github.com/jekyll/jekyll](https://github.com/jekyll/jekyll) and hugo
  and improve appearance.
  [https://help.github.com/en/articles/customizing-css-and-html-in-your-jekyll-theme](https://help.github.com/en/articles/customizing-css-and-html-in-your-jekyll-theme)
- Disable unattended apt package updates during tests.

