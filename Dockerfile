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

RUN cat /tmp/packages.txt | xargs -i xbps-install -y -S -R "${REPO}" {} || true

RUN xbps-install -Su -y

ADD startup.txt /tmp/startup.txt

ADD sshd_config /etc/ssh/sshd_config.d/sshd_config

ADD sudoers /etc/sudoers.d

ADD fstab /etc/fstab

ADD issue.net /etc/issue.net

ADD skel /home/pi

RUN mv /etc/skel /etc/skel.old

ADD skel /etc/skel

RUN mkdir -p /home/pi

RUN mkdir -p /home/pi/.ssh

RUN rm -rf /home/pi/.git

ADD uConsole /home/pi/uConsole

RUN groupadd spi

RUN groupadd i2c

RUN groupadd gpio

RUN groupadd -g 5000 pi

RUN useradd -u 4000 -g pi -s /bin/bash -d /home/pi -G video,adm,dialout,cdrom,audio,plugdev,users,input,spi,i2c,gpio pi

RUN chown pi:pi /home/pi

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

RUN cp arch/arm64/boot/Image ../boot/kernel8.img

RUN cp arch/arm/boot/dts/*.dtb /boot/firmware/

RUN cp arch/arm/boot/dts/broadcom/*.dtb /boot/firmware/

RUN cp arch/arm/boot/dts/overlays/*.dtb* /boot/firmware/overlays/

RUN cp arch/arm/boot/dts/overlays/README /boot/firmware/overlays/

# ENV ARCH=aarch64

RUN usermod -U pi

RUN passwd -d pi

ADD 99-uconsole.rules /etc/udev/rules.d/99-uconsole.rules

WORKDIR /

RUN rm -rf /usr/src/linux
