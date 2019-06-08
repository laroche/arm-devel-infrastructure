DATE := $(shell date +%Y%m%d)

all: debian.img debian-x86.img

debian.img: debian.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian.tar.gz --output debian.img debian.yaml --log debian.log --log-mode 0644
	sudo chown $(USER) debian.img debian.log
	#env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian.tar.gz --output debian.img debian.yaml --log debian.log --log-mode 0644

debian-x86.img: debian-x86.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-x86.tar.gz --output debian-x86.img debian-x86.yaml --log debian-x86.log --log-mode 0644
	sudo chown $(USER) debian-x86.img debian-x86.log
	#env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-x86.tar.gz --output debian-x86.img debian-x86.yaml --log debian-x86.log --log-mode 0644

release: debian.img README.md
	mkdir debian-server-$(DATE)
	ln README.md debian-server-$(DATE)/README-$(DATE).md
	ln debian.img debian-server-$(DATE)/debian-server-$(DATE).img
	zip -r debian-server-$(DATE).zip debian-server-$(DATE)
	rm -fr debian-server-$(DATE)

clean:
	rm -fr debian.img debian.log debian-server-*
	rm -fr debian-x86.img debian-x86.log

distclean: clean
	rm -f debian.tar.gz debian-x86.tar.gz

tag:
	git tag -m "release v$(DATE)" v$(DATE)
	git push origin v($DATE)
	#git push origin --follow-tags

