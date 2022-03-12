#!/bin/bash

LINUX_BUILD_TYPE="kvm_guest"
LINUX_ARCH=x86
LINUX_BUILD_PARALLEISM=2


function print_options() {
    echo "--------------------------"
    echo "VM-OS Build Script"
    echo "Date: $(date)"
    echo "--------------------------"
    echo "Linux profile: ${LINUX_BUILD_TYPE}"
    echo "Linux nproc: ${LINUX_BUILD_PARALLEISM}"
    echo "--------------------------"
}

function build_init() {
    cd init/
    ./build.sh
    cd ../
    cp init/init target/init
}

function build_linux() {
    echo "Building linux..."
    cd linux/
    make clean
    # Build the config files, needed to build the actual kernel
    make allnoconfig
    # Build kvm config specifically
    make ${LINUX_BUILD_TYPE}.config
    CONFIG_BLK_DEV_INITRD=y
    # Build the code, TODO set parallelism
    make -j${LINUX_BUILD_PARALLEISM}
    # Copy binaries
    cd ../
    cp linux/arch/${LINUX_ARCH}/boot/bzImage target/bzImage
    echo "Linux built successfully"
}

function build_image() {
    cd target/
    rm initrd.img
    rm -rf rootfs
    echo "Building the image"
    # Create a blank image
    dd if=/dev/zero of=initrd.img bs=4000 count=1024
    # Make an ext3 file system (TODO change to someting more useful)
    mkfs.ext2 initrd.img
    mkdir rootfs
    mount -o loop initrd.img rootfs
    mkdir rootfs/sbin
    cp init rootfs/init
    mkdir rootfs/dev

    mknod rootfs/dev/ram b 1 0
    mknod rootfs/dev/console c 5 1
    umount rootfs
    # Now package init 
    cd ../
}

function run_image() {
    qemu-system-x86_64 -kernel target/bzImage -initrd target/initrd.img --append "root=/dev/ram init=init"
}

print_options
build_init
build_linux
build_image
run_image