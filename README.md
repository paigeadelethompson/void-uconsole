# Installation 
- Download the zipped image file from the releases page
- Extract the image, and write it to an SD card: `dd if=installer.bin of=/dev/mmcblk0 bs=1M status=progress`

# Linux kernel source 
The source tree is added as a sub-tree to speed up the build process; locked to `3a33f11c48572b9dd0fecac164b3990fc9234da8` but it can be
updated with `git subtree` (Note: patches in https://github.com/clockworkpi/uConsole.git depend on this commit.)

# Testing with QEmu 

- Get the kernel 

```
losetup -P /dev/loop254 installer.bin
mount /dev/loop254p1 /mnt
mkdir krn/ ; cp /mnt/* krn/
umount /mnt
losetup -D /dev/loop254
```

- Start QEmu 

```
qemu-system-aarch64                                                                                                                        \
-M raspi3b                                                                                                                                 \
-kernel krn/kernel8.img                                                                                                                    \
-dtb krn/bcm2710-rpi-3-b.dtb                                                                                                               \
-drive format=raw,file=installer.bin                                                                                                       \
-append "root=/dev/mmcblk0p2 rootfstype=ext4 rootwait console=ttyAMA1,115200 console=tty1 fsck.repair=yes net.ifnames=0 elevator=deadline" \
-netdev user,id=net0,net=169.254.0.0/16,dhcpstart=169.254.0.2,hostfwd=tcp::2222-:22                                                        \
-device usb-net,netdev=net0                                                                                                                \
-device usb-kbd
```
  
# Additional documentation
- https://github.com/raspberrypi/userland
- https://github.com/clockworkpi/uConsole.git
- https://github.com/cuu/skel.git
- https://github-wiki-see.page/m/cuu/uConsole/wiki/How-uConsole-CM4-OS-image-made
- https://www.raspberrypi.com/documentation/computers/linux_kernel.html
