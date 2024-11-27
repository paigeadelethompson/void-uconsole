FROM voidlinux/voidlinux:latest

ENV WANT_32BIT=1

ENV WANT_64BIT=1

ENV WANT_PI4=1

ENV WANT_PI5=1

ENV REPO=https://repo-default.voidlinux.org/current

ENV ARCH=aarch64

ENV XBPS_ARCH=$ARCH

ENV TIMEZONE=UTC

ADD packages.txt /tmp/packages.txt

RUN xbps-install -S -u -y xbps

RUN xbps-pkgdb -m hold linux

RUN xbps-pkgdb -m hold linux-headers

RUN cat /tmp/packages.txt | xargs -i xbps-install -y -S -R "${REPO}" {} || true

RUN xbps-install -Su -y

RUN xbps-remove -yO

RUN xbps-remove -yo

RUN vkpurge rm all

ADD sudoers /etc/sudoers.d

ADD fstab /etc/fstab

RUN mkdir -p /home/pi

RUN mkdir -p /home/pi/.ssh

ADD profile /home/pi/.profile

RUN groupadd spi ; true

RUN groupadd i2c ; true

RUN groupadd gpio ; true

RUN groupadd -g 5000 pi

RUN useradd -u 4000 -g pi -s /bin/bash -d /home/pi -G video,adm,dialout,cdrom,audio,plugdev,users,input,spi,i2c,gpio,scanner,audio,bluetooth pi

RUN chown -R pi:pi /home/pi

WORKDIR /usr/local/bin

RUN wget https://raw.githubusercontent.com/raspberrypi/rpi-update/master/rpi-update

RUN mkdir -p /lib/modules

RUN chmod +x /usr/local/bin/rpi-update

RUN echo y | /usr/local/bin/rpi-update

ADD cmdline.txt /boot/cmdline.txt

ADD config.txt /boot/config.txt

RUN cd /tmp

ADD userland /usr/src/userland

WORKDIR /usr/src/userland

RUN  ./buildme --aarch64

ADD linux /usr/src/linux

WORKDIR /usr/src/linux

RUN make ARCH=arm64 V=1 -j2 modules_install

RUN mkdir -p /boot/overlays

RUN sudo cp arch/arm64/boot/Image.gz /boot/kernel8.img

RUN sudo cp arch/arm64/boot/dts/broadcom/*.dtb /boot/

RUN sudo cp arch/arm64/boot/dts/overlays/*.dtb* /boot/overlays/

RUN sudo cp arch/arm64/boot/dts/overlays/README /boot/overlays/

RUN mkdir /etc/sv/ansible

ADD ansible_service /etc/sv/ansible/run

RUN chmod +x /etc/sv/ansible/run

RUN ln -sfv /etc/sv/socklog-unix /etc/runit/runsvdir/default/ ; true
 
RUN ln -sfv /etc/sv/nanoklogd /etc/runit/runsvdir/default/ ; true

RUN ln -sfv /etc/sv/wpa_supplicant /etc/runit/runsvdir/default/ ; true

RUN ln -sfv /etc/sv/chronyd /etc/runit/runsvdir/default/ ; true

RUN rm -f /etc/wpa_supplicant/wpa_supplicant.conf 

RUN ln -sfv /mnt/sideload/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf ; true

RUN usermod -U pi

RUN usermod -L root

RUN passwd -d pi

ADD 99-uconsole.rules /etc/udev/rules.d/99-uconsole.rules

WORKDIR /

RUN rm -rf /usr/src/linux
