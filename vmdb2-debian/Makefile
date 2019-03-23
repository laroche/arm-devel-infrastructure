DATE := $(shell date +%Y%m%d)

debian.img: debian.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball=debian.tar.gz --output debian.img debian.yaml --log debian.log
	sudo chown $(USER) debian.img debian.log

release: debian.img README.md
	ln debian.img debian-server-$(DATE).img
	zip debian-server-$(DATE).zip README.md debian-server-$(DATE).img
	rm -f debian-server-$(DATE).img

clean:
	rm -f debian.img debian.log debian-server-*.zip debian-server-*.img

distclean: clean
	rm -f debian.tar.gz

tag:
	git tag v$(DATE)

