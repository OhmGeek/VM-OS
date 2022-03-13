#!/bin/bash

# Build options
LINUX_BUILD_TYPE="defconfig"
LINUX_BUILD_PARALLEISM=4
LINUX_ARCH="x86"

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

function build_linux() {
    if [ -f linux/arch/${LINUX_ARCH}/boot/bzImage ]; then
        echo "Skipping linux build, as bzImage already exists."
    else
        echo "Building linux..."
        cd linux/
        make clean
        # Build the config files, needed to build the actual kernel
        make allnoconfig
        # Build kvm config specifically
        make ${LINUX_BUILD_TYPE}
        # Build the code, TODO set parallelism
        make -j${LINUX_BUILD_PARALLEISM}
        cd ../
        echo "Linux built successfully"
    fi

    # As a helper, copy bzImage to top level.
    cp linux/arch/${LINUX_ARCH}/boot/bzImage ./bzImage
}

function build_image() {
    mkdir bootdisk/
    cd bootdisk/

    cp ../init/init ./init

    # Recreate the ramdisk
    find . | cpio --quiet -H newc -o | gzip -9 -n > ../initrd.img
    cd ../
}


print_options
## Start by cleaning
rm -rf bootdisk/
build_init
build_linux
build_image