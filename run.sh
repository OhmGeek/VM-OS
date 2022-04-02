#!/bin/bash

# For now, we use the hard coded kernel (this will change later to use cutting edge kernels, once we fix libc hell)
qemu-system-x86_64 -kernel bzImage -initrd initrd.img -m 2G -enable-kvm --append "console=ttyS0"