DATE := $(shell date +%Y%m%d)

all: debian-amd64.img debian-rpi3-arm64.img

debian-amd64.img: debian-amd64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-amd64.tar.gz --output debian-amd64.img debian-amd64.yaml --log debian-amd64.log --log-mode 0644
	sudo chown $(USER) debian-amd64.img debian-amd64.log
	#env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-amd64.tar.gz --output debian-amd64.img debian-amd64.yaml --log debian-amd64.log --log-mode 0644

debian-rpi3-arm64.img: debian-rpi3-arm64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-rpi3-arm64.tar.gz --output debian-rpi3-arm64.img debian-rpi3-arm64.yaml --log debian-rpi3-arm64.log --log-mode 0644
	sudo chown $(USER) debian-rpi3-arm64.img debian-rpi3-arm64.log
	#env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-rpi3-arm64.tar.gz --output debian-rpi3-arm64.img debian-rpi3-arm64.yaml --log debian-rpi3-arm64.log --log-mode 0644

release: README.md all
	mkdir debian-buster-amd64-core-$(DATE)
	ln README.md debian-buster-amd64-core-$(DATE)/README-$(DATE).md
	ln debian-amd64.img debian-buster-amd64-core-$(DATE)/debian-buster-amd64-core-$(DATE).img
	zip -r debian-buster-amd64-core-$(DATE).zip debian-buster-amd64-core-$(DATE)
	rm -fr debian-buster-amd64-core-$(DATE)
	mkdir debian-buster-rpi3-arm64-core-$(DATE)
	ln README.md debian-buster-rpi3-arm64-core-$(DATE)/README-$(DATE).md
	ln debian-rpi3-arm64.img debian-buster-rpi3-arm64-core-$(DATE)/debian-buster-rpi3-arm64-core-$(DATE).img
	zip -r debian-buster-rpi3-arm64-core-$(DATE).zip debian-buster-rpi3-arm64-core-$(DATE)
	rm -fr debian-buster-rpi3-arm64-core-$(DATE)

clean:
	rm -fr debian-*.log debian-*.img debian-*.zip

distclean: clean
	rm -f debian-*.tar.gz

tag:
	git tag -m "release v$(DATE)" v$(DATE)
	git push origin v($DATE)
	#git push origin --follow-tags

