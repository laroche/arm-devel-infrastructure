DATE := $(shell date +%Y%m%d)

.PHONY: all release clean distclean tag

all: debian-amd64.img debian-amd64-legacy.img debian-rpi3-arm64.img debian-rpi3-armhf.img \
    debian-testing-amd64.img debian-testing-amd64-legacy.img debian-testing-rpi3-arm64.img debian-testing-rpi3-armhf.img

#release: debian-stable-amd64-$(DATE).zip debian-stable-amd64-legacy-$(DATE).zip debian-stable-rpi3-arm64-$(DATE).zip debian-stable-rpi3-armhf-$(DATE).zip \
#    debian-testing-amd64-$(DATE).zip debian-testing-amd64-legacy-$(DATE).zip debian-testing-rpi3-arm64-$(DATE).zip debian-testing-rpi3-armhf-$(DATE).zip

release: debian-stable-amd64-$(DATE).zip debian-stable-amd64-legacy-$(DATE).zip \
    debian-testing-amd64-$(DATE).zip debian-testing-amd64-legacy-$(DATE).zip

define vmdb2
	sudo env -i http_proxy=$(http_proxy) LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$$PATH" vmdb2 --rootfs-tarball debian-$(1).tar.gz --output debian-$(1).img debian-$(1).yaml --log debian-$(1).log
	sudo chown $(USER):$(USER) debian-$(1).img debian-$(1).log
endef

debian-amd64-legacy.img: debian-amd64-legacy.yaml
	$(call vmdb2,amd64-legacy)
	sudo parted -s $@ toggle 1 boot

debian-testing-amd64-legacy.yaml: debian-amd64-legacy.yaml
	sed 's/debootstrap: bookworm/debootstrap: testing/g' < $^ > $@

debian-testing-amd64-legacy.img: debian-testing-amd64-legacy.yaml
	# XXX: TODO: due to hardcoded /dev/loop0:
	#test "X$$(sudo losetup -a)" = "X"
	$(call vmdb2,testing-amd64-legacy)
	sudo parted -s $@ toggle 1 boot

debian-amd64.img: debian-amd64.yaml
	$(call vmdb2,amd64)

debian-testing-amd64.yaml: debian-amd64.yaml
	sed 's/debootstrap: bookworm/debootstrap: testing/g' < $^ > $@

debian-testing-amd64.img: debian-testing-amd64.yaml
	$(call vmdb2,testing-amd64)

debian-rpi3-arm64.img: debian-rpi3-arm64.yaml
	$(call vmdb2,rpi3-arm64)

debian-testing-rpi3-arm64.yaml: debian-rpi3-arm64.yaml
	sed 's/debootstrap: bookworm/debootstrap: testing/g' < $^ | sed -e "s/#- non-free-firmware/- non-free-firmware/g" > $@

debian-testing-rpi3-arm64.img: debian-testing-rpi3-arm64.yaml
	$(call vmdb2,testing-rpi3-arm64)

debian-rpi3-armhf.img: debian-rpi3-armhf.yaml
	$(call vmdb2,rpi3-armhf)

debian-testing-rpi3-armhf.yaml: debian-rpi3-armhf.yaml
	sed 's/debootstrap: bookworm/debootstrap: testing/g' < $^ | sed -e "s/#- non-free-firmware/- non-free-firmware/g" > $@

debian-testing-rpi3-armhf.img: debian-testing-rpi3-armhf.yaml
	$(call vmdb2,testing-rpi3-armhf)

define pack
debian-$(1)-$(DATE).zip: debian-$(2).img README.md
	mkdir debian-$(1)-$(DATE)
	ln README.md debian-$(1)-$(DATE)/README-$(DATE).md
	ln debian-$(2).img debian-$(1)-$(DATE)/debian-$(1)-$(DATE).img
	cd debian-$(1)-$(DATE) && md5sum debian-$(1)-$(DATE).img > debian-$(1)-$(DATE).img.md5
	zip -r debian-$(1)-$(DATE).zip debian-$(1)-$(DATE)
	rm -fr debian-$(1)-$(DATE)
endef

$(eval $(call pack,stable-amd64,amd64))
$(eval $(call pack,testing-amd64,testing-amd64))

$(eval $(call pack,stable-amd64-legacy,amd64-legacy))
$(eval $(call pack,testing-amd64-legacy,testing-amd64-legacy))

$(eval $(call pack,stable-rpi3-arm64,rpi3-arm64))
$(eval $(call pack,testing-rpi3-arm64,testing-rpi3-arm64))

$(eval $(call pack,stable-rpi3-armhf,rpi3-armhf))
$(eval $(call pack,testing-rpi3-armhf,testing-rpi3-armhf))

clean:
	rm -f debian-*.img debian-*.log debian-*.zip wget-log*

distclean: clean
	rm -f debian-*.tar.gz #debian-testing-*.yaml
	rm -f debian-testing-amd64.yaml debian-testing-amd64-legacy.yaml debian-testing-rpi3-arm64.yaml debian-testing-rpi3-armhf.yaml

tag:
	git tag -m "release v$(DATE)" v$(DATE)
	git push origin v$(DATE)
	#git push origin --follow-tags

