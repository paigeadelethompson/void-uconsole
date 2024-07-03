FROM voidlinux/voidlinux:latest

ENV WANT_32BIT=1

ENV WANT_64BIT=1

ENV WANT_PI4=1

ENV WANT_PI5=1

ENV REPO=https://repo-default.voidlinux.org/current

ENV ARCH=aarch64

ENV XBPS_ARCH=$ARCH

ADD packages.txt /tmp/packages.txt

RUN cat packages.txt | xargs -i xbps-install -S -R "${REPO}" {}

RUN xbps-remove base-container-full

ADD startup.txt /tmp/startup.txt

ADD regenerate_ssh_host_keys.service /usr/lib/systemd/system

ADD sshd_config /etc/ssh/sshd_config.d/sshd_config

ADD sudoers /etc/sudoers.d

ADD fstab /etc/fstab

ADD issue.net /etc/issue.net

RUN mkdir /home/pi

RUN mkdir /home/pi/.ssh

RUN groupadd spi

RUN groupadd i2c

RUN groupadd gpio

RUN groupadd -g 5000 pi

RUN useradd -u 4000 -g pi -s /bin/bash -d /home/pi -G sudo,video,adm,dialout,cdrom,audio,plugdev,games,users,input,netdev,spi,i2c,gpio pi

RUN chown pi:pi /home/pi

ADD profile /home/pi/.profile

RUN cd /usr/local/bin && wget https://raw.githubusercontent.com/raspberrypi/rpi-update/master/rpi-update

RUN mkdir -p /lib/modules

RUN chmod +x /usr/local/bin/rpi-update

RUN echo y | /usr/local/bin/rpi-update

ADD cmdline.txt /boot/cmdline.txt

ADD config.txt /boot/config.txt

RUN cd /tmp

RUN git clone https://github.com/raspberrypi/userland /usr/src/userland

RUN cd /usr/src/userland ; ./buildme --aarch64

RUN usermod -U pi

RUN passwd -d pi

RUN echo '/opt/vc/lib' > /etc/ld.so.conf.d/00-vmcs.conf

ADD 99-uconsole.rules /etc/udev/rules.d/99-uconsole.rules

RUN apt -y autoremove

RUN rm -rf /var/lib/apt/lists/*

RUN rm -rf /home
