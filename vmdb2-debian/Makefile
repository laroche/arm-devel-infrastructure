DATE := $(shell date +%Y%m%d)

.PHONY: all release clean distclean tag

all: debian-amd64.img debian-amd64-efi.img debian-rpi3-arm64.img debian-rpi3-armhf.img \
    debian-testing-amd64.img debian-testing-amd64-efi.img debian-unstable-rpi3-arm64.img debian-testing-rpi3-armhf.img \
    #debian-unstable-amd64.img debian-unstable-amd64-efi.img debian-testing-rpi3-arm64.img debian-unstable-rpi3-armhf.img

release: debian-stable-amd64-$(DATE).zip debian-stable-amd64-efi-$(DATE).zip debian-stable-rpi3-arm64-$(DATE).zip debian-stable-rpi3-armhf-$(DATE).zip \
    debian-testing-amd64-$(DATE).zip debian-testing-amd64-efi-$(DATE).zip debian-unstable-rpi3-arm64-$(DATE).zip debian-testing-rpi3-armhf-$(DATE).zip \
    #debian-unstable-amd64-$(DATE).zip debian-unstable-amd64-efi-$(DATE).zip debian-testing-rpi3-arm64-$(DATE).zip debian-unstable-rpi3-armhf-$(DATE).zip

debian-amd64.img: debian-amd64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-amd64.tar.gz --output debian-amd64.img debian-amd64.yaml --log debian-amd64.log --log-mode 0644
	sudo chown $(USER) debian-amd64.img debian-amd64.log
	sudo parted -s debian-amd64.img toggle 1 boot

debian-testing-amd64.yaml: debian-amd64.yaml
	sed 's/qemu-debootstrap: buster/qemu-debootstrap: testing/g' < debian-amd64.yaml | grep -v linux-image-rt > debian-testing-amd64.yaml

debian-testing-amd64.img: debian-testing-amd64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-testing-amd64.tar.gz --output debian-testing-amd64.img debian-testing-amd64.yaml --log debian-testing-amd64.log --log-mode 0644
	sudo chown $(USER) debian-testing-amd64.img debian-testing-amd64.log
	sudo parted -s debian-testing-amd64.img toggle 1 boot

debian-unstable-amd64.yaml: debian-amd64.yaml
	sed 's/qemu-debootstrap: buster/qemu-debootstrap: unstable/g' < debian-amd64.yaml | grep -v linux-image-rt > debian-unstable-amd64.yaml

debian-unstable-amd64.img: debian-unstable-amd64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-unstable-amd64.tar.gz --output debian-unstable-amd64.img debian-unstable-amd64.yaml --log debian-unstable-amd64.log --log-mode 0644
	sudo chown $(USER) debian-unstable-amd64.img debian-unstable-amd64.log
	sudo parted -s debian-unstable-amd64.img toggle 1 boot

debian-amd64-efi.img: debian-amd64-efi.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-amd64-efi.tar.gz --output debian-amd64-efi.img debian-amd64-efi.yaml --log debian-amd64-efi.log --log-mode 0644
	sudo chown $(USER) debian-amd64-efi.img debian-amd64-efi.log

debian-testing-amd64-efi.yaml: debian-amd64-efi.yaml
	sed 's/qemu-debootstrap: buster/qemu-debootstrap: testing/g' < debian-amd64-efi.yaml | grep -v linux-image-rt > debian-testing-amd64-efi.yaml

debian-testing-amd64-efi.img: debian-testing-amd64-efi.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-testing-amd64-efi.tar.gz --output debian-testing-amd64-efi.img debian-testing-amd64-efi.yaml --log debian-testing-amd64-efi.log --log-mode 0644
	sudo chown $(USER) debian-testing-amd64-efi.img debian-testing-amd64-efi.log

debian-unstable-amd64-efi.yaml: debian-amd64-efi.yaml
	sed 's/qemu-debootstrap: buster/qemu-debootstrap: unstable/g' < debian-amd64-efi.yaml | grep -v linux-image-rt > debian-unstable-amd64-efi.yaml

debian-unstable-amd64-efi.img: debian-unstable-amd64-efi.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-unstable-amd64-efi.tar.gz --output debian-unstable-amd64-efi.img debian-unstable-amd64-efi.yaml --log debian-unstable-amd64-efi.log --log-mode 0644
	sudo chown $(USER) debian-unstable-amd64-efi.img debian-unstable-amd64-efi.log

debian-rpi3-arm64.img: debian-rpi3-arm64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-rpi3-arm64.tar.gz --output debian-rpi3-arm64.img debian-rpi3-arm64.yaml --log debian-rpi3-arm64.log --log-mode 0644
	sudo chown $(USER) debian-rpi3-arm64.img debian-rpi3-arm64.log

debian-testing-rpi3-arm64.yaml: debian-rpi3-arm64.yaml
	sed 's/qemu-debootstrap: buster/qemu-debootstrap: testing/g' < debian-rpi3-arm64.yaml > debian-testing-rpi3-arm64.yaml

debian-testing-rpi3-arm64.img: debian-testing-rpi3-arm64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-testing-rpi3-arm64.tar.gz --output debian-testing-rpi3-arm64.img debian-testing-rpi3-arm64.yaml --log debian-testing-rpi3-arm64.log --log-mode 0644
	sudo chown $(USER) debian-testing-rpi3-arm64.img debian-testing-rpi3-arm64.log

debian-unstable-rpi3-arm64.yaml: debian-rpi3-arm64.yaml
	sed 's/qemu-debootstrap: buster/qemu-debootstrap: unstable/g' < debian-rpi3-arm64.yaml > debian-unstable-rpi3-arm64.yaml

debian-unstable-rpi3-arm64.img: debian-unstable-rpi3-arm64.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-unstable-rpi3-arm64.tar.gz --output debian-unstable-rpi3-arm64.img debian-unstable-rpi3-arm64.yaml --log debian-unstable-rpi3-arm64.log --log-mode 0644
	sudo chown $(USER) debian-unstable-rpi3-arm64.img debian-unstable-rpi3-arm64.log

debian-rpi3-armhf.img: debian-rpi3-armhf.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-rpi3-armhf.tar.gz --output debian-rpi3-armhf.img debian-rpi3-armhf.yaml --log debian-rpi3-armhf.log --log-mode 0644
	sudo chown $(USER) debian-rpi3-armhf.img debian-rpi3-armhf.log

debian-testing-rpi3-armhf.yaml: debian-rpi3-armhf.yaml
	sed 's/qemu-debootstrap: buster/qemu-debootstrap: testing/g' < debian-rpi3-armhf.yaml | grep -v linux-image-rt > debian-testing-rpi3-armhf.yaml

debian-testing-rpi3-armhf.img: debian-testing-rpi3-armhf.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-testing-rpi3-armhf.tar.gz --output debian-testing-rpi3-armhf.img debian-testing-rpi3-armhf.yaml --log debian-testing-rpi3-armhf.log --log-mode 0644
	sudo chown $(USER) debian-testing-rpi3-armhf.img debian-testing-rpi3-armhf.log

debian-unstable-rpi3-armhf.yaml: debian-rpi3-armhf.yaml
	sed 's/qemu-debootstrap: buster/qemu-debootstrap: unstable/g' < debian-rpi3-armhf.yaml | grep -v linux-image-rt > debian-unstable-rpi3-armhf.yaml

debian-unstable-rpi3-armhf.img: debian-unstable-rpi3-armhf.yaml
	sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-unstable-rpi3-armhf.tar.gz --output debian-unstable-rpi3-armhf.img debian-unstable-rpi3-armhf.yaml --log debian-unstable-rpi3-armhf.log --log-mode 0644
	sudo chown $(USER) debian-unstable-rpi3-armhf.img debian-unstable-rpi3-armhf.log

debian-stable-amd64-$(DATE).zip: debian-amd64.img README.md
	mkdir debian-stable-amd64-$(DATE)
	ln README.md debian-stable-amd64-$(DATE)/README-$(DATE).md
	ln debian-amd64.img debian-stable-amd64-$(DATE)/debian-stable-amd64-$(DATE).img
	cd debian-stable-amd64-$(DATE) && md5sum debian-stable-amd64-$(DATE).img > debian-stable-amd64-$(DATE).img.md5
	zip -r debian-stable-amd64-$(DATE).zip debian-stable-amd64-$(DATE)
	rm -fr debian-stable-amd64-$(DATE)

debian-testing-amd64-$(DATE).zip: debian-testing-amd64.img README.md
	mkdir debian-testing-amd64-$(DATE)
	ln README.md debian-testing-amd64-$(DATE)/README-$(DATE).md
	ln debian-testing-amd64.img debian-testing-amd64-$(DATE)/debian-testing-amd64-$(DATE).img
	cd debian-testing-amd64-$(DATE) && md5sum debian-testing-amd64-$(DATE).img > debian-testing-amd64-$(DATE).img.md5
	zip -r debian-testing-amd64-$(DATE).zip debian-testing-amd64-$(DATE)
	rm -fr debian-testing-amd64-$(DATE)

debian-unstable-amd64-$(DATE).zip: debian-unstable-amd64.img README.md
	mkdir debian-unstable-amd64-$(DATE)
	ln README.md debian-unstable-amd64-$(DATE)/README-$(DATE).md
	ln debian-unstable-amd64.img debian-unstable-amd64-$(DATE)/debian-unstable-amd64-$(DATE).img
	cd debian-unstable-amd64-$(DATE) && md5sum debian-unstable-amd64-$(DATE).img > debian-unstable-amd64-$(DATE).img.md5
	zip -r debian-unstable-amd64-$(DATE).zip debian-unstable-amd64-$(DATE)
	rm -fr debian-unstable-amd64-$(DATE)

debian-stable-amd64-efi-$(DATE).zip: debian-amd64-efi.img README.md
	mkdir debian-stable-amd64-efi-$(DATE)
	ln README.md debian-stable-amd64-efi-$(DATE)/README-$(DATE).md
	ln debian-amd64-efi.img debian-stable-amd64-efi-$(DATE)/debian-stable-amd64-efi-$(DATE).img
	cd debian-stable-amd64-efi-$(DATE) && md5sum debian-stable-amd64-efi-$(DATE).img > debian-stable-amd64-efi-$(DATE).img.md5
	zip -r debian-stable-amd64-efi-$(DATE).zip debian-stable-amd64-efi-$(DATE)
	rm -fr debian-stable-amd64-efi-$(DATE)

debian-testing-amd64-efi-$(DATE).zip: debian-testing-amd64-efi.img README.md
	mkdir debian-testing-amd64-efi-$(DATE)
	ln README.md debian-testing-amd64-efi-$(DATE)/README-$(DATE).md
	ln debian-testing-amd64-efi.img debian-testing-amd64-efi-$(DATE)/debian-testing-amd64-efi-$(DATE).img
	cd debian-testing-amd64-efi-$(DATE) && md5sum debian-testing-amd64-efi-$(DATE).img > debian-testing-amd64-efi-$(DATE).img.md5
	zip -r debian-testing-amd64-efi-$(DATE).zip debian-testing-amd64-efi-$(DATE)
	rm -fr debian-testing-amd64-efi-$(DATE)

debian-unstable-amd64-efi-$(DATE).zip: debian-unstable-amd64-efi.img README.md
	mkdir debian-unstable-amd64-efi-$(DATE)
	ln README.md debian-unstable-amd64-efi-$(DATE)/README-$(DATE).md
	ln debian-unstable-amd64-efi.img debian-unstable-amd64-efi-$(DATE)/debian-unstable-amd64-efi-$(DATE).img
	cd debian-unstable-amd64-efi-$(DATE) && md5sum debian-unstable-amd64-efi-$(DATE).img > debian-unstable-amd64-efi-$(DATE).img.md5
	zip -r debian-unstable-amd64-efi-$(DATE).zip debian-unstable-amd64-efi-$(DATE)
	rm -fr debian-unstable-amd64-efi-$(DATE)

debian-stable-rpi3-arm64-$(DATE).zip: debian-rpi3-arm64.img README.md
	mkdir debian-stable-rpi3-arm64-$(DATE)
	ln README.md debian-stable-rpi3-arm64-$(DATE)/README-$(DATE).md
	ln debian-rpi3-arm64.img debian-stable-rpi3-arm64-$(DATE)/debian-stable-rpi3-arm64-$(DATE).img
	cd debian-stable-rpi3-arm64-$(DATE) && md5sum debian-stable-rpi3-arm64-$(DATE).img > debian-stable-rpi3-arm64-$(DATE).img.md5
	zip -r debian-stable-rpi3-arm64-$(DATE).zip debian-stable-rpi3-arm64-$(DATE)
	rm -fr debian-stable-rpi3-arm64-$(DATE)

debian-testing-rpi3-arm64-$(DATE).zip: debian-testing-rpi3-arm64.img README.md
	mkdir debian-testing-rpi3-arm64-$(DATE)
	ln README.md debian-testing-rpi3-arm64-$(DATE)/README-$(DATE).md
	ln debian-testing-rpi3-arm64.img debian-testing-rpi3-arm64-$(DATE)/debian-testing-rpi3-arm64-$(DATE).img
	cd debian-testing-rpi3-arm64-$(DATE) && md5sum debian-testing-rpi3-arm64-$(DATE).img > debian-testing-rpi3-arm64-$(DATE).img.md5
	zip -r debian-testing-rpi3-arm64-$(DATE).zip debian-testing-rpi3-arm64-$(DATE)
	rm -fr debian-testing-rpi3-arm64-$(DATE)

debian-unstable-rpi3-arm64-$(DATE).zip: debian-unstable-rpi3-arm64.img README.md
	mkdir debian-unstable-rpi3-arm64-$(DATE)
	ln README.md debian-unstable-rpi3-arm64-$(DATE)/README-$(DATE).md
	ln debian-unstable-rpi3-arm64.img debian-unstable-rpi3-arm64-$(DATE)/debian-unstable-rpi3-arm64-$(DATE).img
	cd debian-unstable-rpi3-arm64-$(DATE) && md5sum debian-unstable-rpi3-arm64-$(DATE).img > debian-unstable-rpi3-arm64-$(DATE).img.md5
	zip -r debian-unstable-rpi3-arm64-$(DATE).zip debian-unstable-rpi3-arm64-$(DATE)
	rm -fr debian-unstable-rpi3-arm64-$(DATE)

debian-stable-rpi3-armhf-$(DATE).zip: debian-rpi3-armhf.img README.md
	mkdir debian-stable-rpi3-armhf-$(DATE)
	ln README.md debian-stable-rpi3-armhf-$(DATE)/README-$(DATE).md
	ln debian-rpi3-armhf.img debian-stable-rpi3-armhf-$(DATE)/debian-stable-rpi3-armhf-$(DATE).img
	cd debian-stable-rpi3-armhf-$(DATE) && md5sum debian-stable-rpi3-armhf-$(DATE).img > debian-stable-rpi3-armhf-$(DATE).img.md5
	zip -r debian-stable-rpi3-armhf-$(DATE).zip debian-stable-rpi3-armhf-$(DATE)
	rm -fr debian-stable-rpi3-armhf-$(DATE)

debian-testing-rpi3-armhf-$(DATE).zip: debian-testing-rpi3-armhf.img README.md
	mkdir debian-testing-rpi3-armhf-$(DATE)
	ln README.md debian-testing-rpi3-armhf-$(DATE)/README-$(DATE).md
	ln debian-testing-rpi3-armhf.img debian-testing-rpi3-armhf-$(DATE)/debian-testing-rpi3-armhf-$(DATE).img
	cd debian-testing-rpi3-armhf-$(DATE) && md5sum debian-testing-rpi3-armhf-$(DATE).img > debian-testing-rpi3-armhf-$(DATE).img.md5
	zip -r debian-testing-rpi3-armhf-$(DATE).zip debian-testing-rpi3-armhf-$(DATE)
	rm -fr debian-testing-rpi3-armhf-$(DATE)

debian-unstable-rpi3-armhf-$(DATE).zip: debian-unstable-rpi3-armhf.img README.md
	mkdir debian-unstable-rpi3-armhf-$(DATE)
	ln README.md debian-unstable-rpi3-armhf-$(DATE)/README-$(DATE).md
	ln debian-unstable-rpi3-armhf.img debian-unstable-rpi3-armhf-$(DATE)/debian-unstable-rpi3-armhf-$(DATE).img
	cd debian-unstable-rpi3-armhf-$(DATE) && md5sum debian-unstable-rpi3-armhf-$(DATE).img > debian-unstable-rpi3-armhf-$(DATE).img.md5
	zip -r debian-unstable-rpi3-armhf-$(DATE).zip debian-unstable-rpi3-armhf-$(DATE)
	rm -fr debian-unstable-rpi3-armhf-$(DATE)

clean:
	rm -f debian-*.img debian-*.log debian-*.zip

distclean: clean
	rm -f debian-*.tar.gz debian-testing-*.yaml debian-unstable-*.yaml

tag:
	git tag -m "release v$(DATE)" v$(DATE)
	git push origin v$(DATE)
	#git push origin --follow-tags

