## todo list

Things that could be improved in the future:

- Generated grub config shows too many entries from local system.
  Fixed by first update-grub invocation on an installed system.
- grub installed into partition instead of full disk?
- For msdos partitioning the 'boot' flag is not set. (No real problem.)
- Check if the partioning is aligned properly.
- grub keyboard layout is us, change this to de.
- Add de specific configurations to docu.
- Compile own kernel for armhf.
- Change name of own rpi3 kernel. Can an image then be made with
  generic arm64 efi boot which also has a rpi3 kernel?
  (EFI partition not the first one?)
- Automatically recompile new Debian kernels on each checkin into their
  git server 'salsa'.
- Provide a Debian repository with newer kernels instead of downloads.
  Use github pages for this?
- Crosscompile the armhf/arm64 kernels on x86 for faster compile times. (done)
- Install chromium directly from Google or are newer versions
  available for stable? Resolve this by using unstable for now.
  https://wiki.debian.org/DebianRepository/Unofficial
  deb http://dl.google.com/linux/chrome/deb/ stable main
- For documentation, check out https://github.com/jekyll/jekyll and hugo
  and improve appearance.
  https://help.github.com/en/articles/customizing-css-and-html-in-your-jekyll-theme

