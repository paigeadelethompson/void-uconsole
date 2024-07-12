![uConsole](https://static.wixstatic.com/media/3833f7_9e9fc3ed88534fb0b1eae043b3d5906e~mv2.png/v1/fill/w_480,h_480,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/3833f7_9e9fc3ed88534fb0b1eae043b3d5906e~mv2.png)

- [https://www.clockworkpi.com/uconsole](https://www.clockworkpi.com/uconsole)

# Installation 
- Download the zipped image file from the releases page
- Extract the image, and write it to an SD card: `dd if=installer.bin of=/dev/mmcblk0 bs=1M status=progress`

# Linux kernel source 
The source tree is added as a sub-tree to speed up the build process ~(from https://github.com/raspberrypi/linux.git); and locked to 3a33f11c48572b9dd0fecac164b3990fc9234da8~ but it can be
updated with `git subtree` (Note: patches in https://github.com/clockworkpi/uConsole.git depend on this commit, so it will likely need to be updated later.)

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
  
# Additional documentation
- https://github.com/raspberrypi/userland
- https://github.com/clockworkpi/uConsole.git
- https://github.com/cuu/skel.git
- https://github-wiki-see.page/m/cuu/uConsole/wiki/How-uConsole-CM4-OS-image-made
- https://www.raspberrypi.com/documentation/computers/linux_kernel.html
