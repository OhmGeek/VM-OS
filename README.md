# VM-OS
A linux distribution that runs QEMU as pid-1


# Initrd build process (WIP)
This uses [mkinitramfs](https://github.com/venomlinux/mkinitramfs) with the existing kernel:
- We add all files in "/bin", "/dev", "/lib/firmware", "run" "sys" "proc" "user" "etc/modprobe.d" "etc/udev/rules.d" into the image
- We symlink lib64 to lib
- We symlink /usr/bin to /bin
- We symlink /sbin to bin
- We symlink /usr/sbin to /bin
- We add modules from kernel/drivers/*, kernel/lib, kernel/fs, kernel/crypto to /lib/modules/$KERNEL/$module

We currently get various libc errors. We should use busybox to avoid these.