#!/bin/bash

function print_options() {
    echo "--------------------------"
    echo "VM-OS Build Script"
    echo "Date: $(date)"
    echo "--------------------------"

    echo "--------------------------"
}

function build_init() {
    cd init/
    ./build.sh
    cd ../
}

## Commented for now (using /boot/vmlinuz-* from Fedora 35 local install)
# function build_linux() {
#     echo "Building linux..."
#     cd linux/
#     make clean
#     # Build the config files, needed to build the actual kernel
#     make allnoconfig
#     # Build kvm config specifically
#     make ${LINUX_BUILD_TYPE}.config
#     CONFIG_BLK_DEV_INITRD=y
#     # Build the code, TODO set parallelism
#     make -j${LINUX_BUILD_PARALLEISM}
#     # Copy binaries
#     cd ../
#     cp linux/arch/${LINUX_ARCH}/boot/bzImage target/bzImage
#     echo "Linux built successfully"
# }

function build_image() {
    mkdir bootdisk/
    cd bootdisk/
    mkinitramfs -o initrd.img

    # Extract to local dir
    gzip -cd initrd.img | cpio -imd --quiet
    rm initrd.img

    # Delete ./init as we will replace this with our own.
    rm ./init
    # cp ../init/init ./init
    cp bin/bash ./init
    # Recreate the ramdisk
    find . | cpio --quiet -H newc -o | gzip -9 -n > ../initrd.img
    cd ../
}


print_options
rm -rf bootdisk/
build_init
build_image