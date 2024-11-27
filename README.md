![uConsole](https://static.wixstatic.com/media/3833f7_9e9fc3ed88534fb0b1eae043b3d5906e~mv2.png/v1/fill/w_480,h_480,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/3833f7_9e9fc3ed88534fb0b1eae043b3d5906e~mv2.png)

- [https://www.clockworkpi.com/uconsole](https://www.clockworkpi.com/uconsole)

# Installation 
- Download the zipped image file from the releases page
- Extract the image, and write it to an SD card: `dd if=installer.bin of=/dev/mmcblk0 bs=1M status=progress`
## Ansible sideload 
- Mount the `sideload` partition of the SDcard and add ansible playbooks, for MacOS get the device name with `diskutil list` then:
```
sudo mkdir /Volumes/sideload
sudo mount -t exfat /dev/disk4s2 /Volumes/sideload
```
- My playbooks can be found here: https://github.com/paigeadelethompson/paige-ansible-uconsole `git clone` this to `/Volumes/sideload` and edit the `wpa_supplicant.conf`
file to contain the WiFi configuration that should be used for the post-boot installation. 
- Unmount the sideload partition `sudo umount /Volumes/sideload`
- Eject the SDCard
- Insert the SDCard into the device and boot it (ansible will run at boot.)
- default username is `pi` no password is set, pi has `sudo`. 
## Resize disk without Ansible
- Boot into the image on the uConsole and login as user `pi`
- This image is sized to fit on any SD that is at least 4GB or larger. Therefore the root partitition is small and should be resized to use the extent of the provided SD card:
- `sudo parted show`
- `sudo parted rm 3`
- `sudo parted mkpart primary btrfs 576M -1`
- `sudo partprobe`
- `sudo btrfs fi resize max /`
- reboot

# Linux kernel source 
The source tree is added as a sub-tree to speed up the build process ~(from https://github.com/raspberrypi/linux.git); and locked to 3a33f11c48572b9dd0fecac164b3990fc9234da8~ but it can be
updated with `git subtree` (Note: patches in https://github.com/clockworkpi/uConsole.git depend on this commit, so it will likely need to be updated later.)

- updated again Sat 28th September 2024 in commit: `c36050235066eb04c98f429384739faa2632ac15`
- recently updated to: https://github.com/ak-rex/ClockworkPi-linux.git (rpi-6.6.y HEAD) (7-9-24)

# Image size
Minimum SD size is 4GB, to scale up: 
```
qemu-img resize installer.bin 16G
losetup -P /dev/loop127 installer.bin
parted /dev/loop127
```
delete the second partition, and recreate it; then run: 
```
btrfs filesystem resize +12G /dev/loop127p2
losetup -d /dev/loop127
dd if=installer.bin of=/dev/mmcblk0 bs=1M status=progress
```

# QEmu testing 
My current version of QEmu only has a raspi3b machine type, but the 4b is apparently supported in newer versions. 
For more info: https://www.qemu.org/docs/master/system/arm/raspi.html

use `losetup` and mount the first partition to retrieve the kernel and dtbs, then:
```
qemu-system-aarch64                                                                                           \
-M raspi3b                                                                                                    \
-kernel kernel8.img                                                                                           \
-dtb bcm2710-rpi-3-b.dtb                                                                                      \
-drive format=raw,file=installer.bin                                                                          \
-append "console=serial0,115200n8 console=tty0 root=/dev/mmcblk0p2 rootfstype=btrfs fsck.repair=yes rootwait" \
-netdev user,id=net0,net=169.254.0.0/16,dhcpstart=169.254.0.2,hostfwd=tcp::2222-:22                           \
-device usb-net,netdev=net0                                                                                   \
-device usb-kbd                                                                                               \
-device usb-mouse
```

# Common issues 
- `xbps-install` TLS failures; your clock is not synchronized. Chrony is part of the base image, but requires network connectivity to sync, you may need to restart chrony: `sv restart chronyd` after connecting to the network. 

# Additional documentation
- https://github.com/raspberrypi/userland
- https://github.com/clockworkpi/uConsole.git
- https://github.com/cuu/skel.git
- https://github-wiki-see.page/m/cuu/uConsole/wiki/How-uConsole-CM4-OS-image-made
- https://www.raspberrypi.com/documentation/computers/linux_kernel.html

# Other considerations 
- https://lwn.net/Articles/549580/ (NO_HZ_FULL is enabled for the kernel that is compiled for this image, this is an option that I"ve already been using for awhile now and just requires a `nohz_full=1-3` (allowing RCUs to be offloaded to CPU 0) in order to work. The takeaway is that these cores can remain in a low power sleep state for longer while they're not being used.
- `CONFIG_HZ_1000` is selected for the kernel timer period; this allows tasks to spend up to 1ms before a context switch occurs. This is most ideal for tasks like computer graphics (games, video, low latency audio workstations, etc.) It might be considered somewhat less ideal for things like network services (web servers serving web pages) where `CONFIG_HZ_250` (the default) is a better fit. Moreover and as I mentioned previously, this is a low latency option that can also serve operation of something such as a 3D printer as well, though in the case of a 3D printer the previous NO_HZ option would be better exchanged for `CONFIG_HZ_PERIODIC` to ensure that the kernel is constantly processing RCUs as much as possible. IIRC, `CONFIG_PREEMPT` and related options are also key for processes which require low latency as it allows a process with a sufficient `rtprio` to "preempt" the kernel's scheduling preferences. 
- BTRFS is as good of a choice as any these days but for all of the features that it has copy-on-write, native compression, and subvolumes I would say it's the best option for a general purpose filesystem. If you use Docker in any capacity, it will make the best use of these features by creating subvolumes for containers. Subvolumes do not duplicate data until a subvolume is modified (copy-on-write) thus allowing for a lot of space to be saved when creating containers. The options `rw,noatime,noautodefrag,compress=zstd:15` are given in the fstab to ensure minimal utilization of the SDCard in order to reduce wear. It may be interesting to see what the percieved advantages of something like F2FS are over BTRFS especially as it relates to log tree handling. I'm not 100% certain but it sounds a lot like what BTRFS inherently is good at is essentially what F2FS does in order to minimize I/O and media wear. The simple answer; I've used BTRFS on SDCards for years and I can't think of any which actually failed despite the abuse I put on them--it doesn't really matter. 
