# Installation 
- Download the zipped image file from the releases page
- Extract the image, and write it to an SD card: `dd if=installer.bin of=/dev/mmcblk0 bs=1M status=progress`

# Linux kernel source 
The source tree is added as a sub-tree to speed up the build process; locked to `3a33f11c48572b9dd0fecac164b3990fc9234da8` but it can be
updated with `git subtree` (Note: patches in https://github.com/clockworkpi/uConsole.git depend on this commit.)

# Image size
Minimum SD size is 8GB, to scale up: 
```
qemu-img resize installer.bin 16G
losetup -P /dev/loop127 installer.bin
parted /dev/loop127
```
delete the second partition, and recreate it; then run: 
```
resize2fs /dev/loop127p2
losetup -d /dev/loop127
dd if=installer.bin of=/dev/mmcblk0 bs=1M status=progress
```
  
# Additional documentation
- https://github.com/raspberrypi/userland
- https://github.com/clockworkpi/uConsole.git
- https://github.com/cuu/skel.git
- https://github-wiki-see.page/m/cuu/uConsole/wiki/How-uConsole-CM4-OS-image-made
- https://www.raspberrypi.com/documentation/computers/linux_kernel.html
