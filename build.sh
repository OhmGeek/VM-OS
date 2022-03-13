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
build_image