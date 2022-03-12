#!/bin/bash

# For now, we use the hard coded kernel (this will change later to use cutting edge kernels, once we fix libc hell)
qemu-system-x86_64 -kernel /boot/vmlinuz-5.14.16-301.fc35.x86_64 -initrd initrd.img -m 2G -append "console=ttyS0 init=/init"