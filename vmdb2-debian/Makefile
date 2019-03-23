DATE := $(shell date +%Y%m%d)

debian.img: debian.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball=debian.tar.gz --output debian.img debian.yaml --log debian.log
	sudo chown $(USER) debian.img debian.log

release: debian.img README.md
	mkdir debian-server-$(DATE)
	ln README.md debian-server-$(DATE)/README-$(DATE).md
	ln debian.img debian-server-$(DATE)/debian-server-$(DATE).img
	zip debian-server-$(DATE).zip debian-server-$(DATE)
	rm -fr debian-server-$(DATE)

clean:
	rm -fr debian.img debian.log debian-server-*

distclean: clean
	rm -f debian.tar.gz

tag:
	git tag -m "release v$(DATE)" v$(DATE)
	git push origin v($DATE)
	#git push origin --follow-tags

