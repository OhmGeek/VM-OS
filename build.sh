#!/bin/bash

LINUX_BUILD_TYPE="kvm_guest"
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
}

function build_linux() {
    echo "Building linux..."
    cd linux/
    make clean
    # Build the config files, needed to build the actual kernel
    make allnoconfig
    # Build kvm config specifically
    make ${LINUX_BUILD_TYPE}.config
    # Build the code, TODO set parallelism
    make -j${LINUX_BUILD_PARALLEISM}
    cd ../
    echo "Linux built successfully"
}

build_init
build_linux
