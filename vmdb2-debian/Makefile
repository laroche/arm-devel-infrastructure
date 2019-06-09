DATE := $(shell date +%Y%m%d)

all: debian-amd64.img debian-amd64-xfce.img debian-rpi3-arm64.img debian-rpi3-armhf.img

release: debian-buster-amd64-core-$(DATE).zip debian-buster-amd64-xfce-$(DATE).zip debian-buster-rpi3-arm64-core-$(DATE).zip debian-buster-rpi3-armhf-core-$(DATE).zip

debian-amd64.img: debian-amd64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-amd64.tar.gz --output debian-amd64.img debian-amd64.yaml --log debian-amd64.log --log-mode 0644
	sudo chown $(USER) debian-amd64.img debian-amd64.log
	#env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-amd64.tar.gz --output debian-amd64.img debian-amd64.yaml --log debian-amd64.log --log-mode 0644

debian-amd64-xfce.img: debian-amd64-xfce.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-amd64-xfce.tar.gz --output debian-amd64-xfce.img debian-amd64-xfce.yaml --log debian-amd64-xfce.log --log-mode 0644
	sudo chown $(USER) debian-amd64-xfce.img debian-amd64-xfce.log
	#env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-amd64-xfce.tar.gz --output debian-amd64-xfce.img debian-amd64-xfce.yaml --log debian-amd64-xfce.log --log-mode 0644

debian-rpi3-arm64.img: debian-rpi3-arm64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-rpi3-arm64.tar.gz --output debian-rpi3-arm64.img debian-rpi3-arm64.yaml --log debian-rpi3-arm64.log --log-mode 0644
	sudo chown $(USER) debian-rpi3-arm64.img debian-rpi3-arm64.log
	#env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-rpi3-arm64.tar.gz --output debian-rpi3-arm64.img debian-rpi3-arm64.yaml --log debian-rpi3-arm64.log --log-mode 0644

debian-rpi3-armhf.img: debian-rpi3-armhf.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-rpi3-armhf.tar.gz --output debian-rpi3-armhf.img debian-rpi3-armhf.yaml --log debian-rpi3-armhf.log --log-mode 0644
	sudo chown $(USER) debian-rpi3-armhf.img debian-rpi3-armhf.log
	#env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-rpi3-armhf.tar.gz --output debian-rpi3-armhf.img debian-rpi3-armhf.yaml --log debian-rpi3-armhf.log --log-mode 0644

debian-buster-amd64-core-$(DATE).zip: debian-amd64.img README.md
	mkdir debian-buster-amd64-core-$(DATE)
	ln README.md debian-buster-amd64-core-$(DATE)/README-$(DATE).md
	ln debian-amd64.img debian-buster-amd64-core-$(DATE)/debian-buster-amd64-core-$(DATE).img
	cd debian-buster-amd64-core-$(DATE) && md5sum debian-buster-amd64-core-$(DATE).img > debian-buster-amd64-core-$(DATE).img.md5
	zip -r debian-buster-amd64-core-$(DATE).zip debian-buster-amd64-core-$(DATE)
	rm -fr debian-buster-amd64-core-$(DATE)

debian-buster-amd64-xfce-$(DATE).zip: debian-amd64-xfce.img README.md
	mkdir debian-buster-amd64-xfce-$(DATE)
	ln README.md debian-buster-amd64-xfce-$(DATE)/README-$(DATE).md
	ln debian-amd64-xfce.img debian-buster-amd64-xfce-$(DATE)/debian-buster-amd64-xfce-$(DATE).img
	cd debian-buster-amd64-xfce-$(DATE) && md5sum debian-buster-amd64-xfce-$(DATE).img > debian-buster-amd64-xfce-$(DATE).img.md5
	zip -r debian-buster-amd64-xfce-$(DATE).zip debian-buster-amd64-xfce-$(DATE)
	rm -fr debian-buster-amd64-xfce-$(DATE)

debian-buster-rpi3-arm64-core-$(DATE).zip: debian-rpi3-arm64.img README.md
	mkdir debian-buster-rpi3-arm64-core-$(DATE)
	ln README.md debian-buster-rpi3-arm64-core-$(DATE)/README-$(DATE).md
	ln debian-rpi3-arm64.img debian-buster-rpi3-arm64-core-$(DATE)/debian-buster-rpi3-arm64-core-$(DATE).img
	cd debian-buster-rpi3-arm64-core-$(DATE) && md5sum debian-buster-rpi3-arm64-core-$(DATE).img > debian-buster-rpi3-arm64-core-$(DATE).img.md5
	zip -r debian-buster-rpi3-arm64-core-$(DATE).zip debian-buster-rpi3-arm64-core-$(DATE)
	rm -fr debian-buster-rpi3-arm64-core-$(DATE)

debian-buster-rpi3-armhf-core-$(DATE).zip: debian-rpi3-armhf.img README.md
	mkdir debian-buster-rpi3-armhf-core-$(DATE)
	ln README.md debian-buster-rpi3-armhf-core-$(DATE)/README-$(DATE).md
	ln debian-rpi3-armhf.img debian-buster-rpi3-armhf-core-$(DATE)/debian-buster-rpi3-armhf-core-$(DATE).img
	cd debian-buster-rpi3-armhf-core-$(DATE) && md5sum debian-buster-rpi3-armhf-core-$(DATE).img > debian-buster-rpi3-armhf-core-$(DATE).img.md5
	zip -r debian-buster-rpi3-armhf-core-$(DATE).zip debian-buster-rpi3-armhf-core-$(DATE)
	rm -fr debian-buster-rpi3-armhf-core-$(DATE)

clean:
	rm -fr debian-*.log debian-*.img debian-*.zip

distclean: clean
	rm -f debian-*.tar.gz

tag:
	git tag -m "release v$(DATE)" v$(DATE)
	git push origin v$(DATE)
	#git push origin --follow-tags

