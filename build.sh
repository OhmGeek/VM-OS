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

    # Before we copy xemu-system-x86_64, copy all libraries
    mkdir lib64
    mkdir bin
    mkdir lib
    mkdir -p usr/share/qemu
    mkdir -p usr/share/bios
    mkdir -p usr/share/ipxe
    mkdir -p usr/share/ipxe.efi
    # List the dynamic libraries required
    QEMU_LIBS=$(ldd /usr/bin/qemu-system-x86_64 | sed 's/.*=>//' | sed 's/(.*)//' | awk 'NR !=1 { print substr($0, 9) }' | xargs)

    echo "Copying ${QEMU_LIBS} from system to OS."
    for LIB in ${QEMU_LIBS}
    do
        cp "/lib64/${LIB}" "lib64/${LIB}"
    done

    # Copy /lib64/qemu/* to add acceleration libraries
    mkdir lib64/qemu
    cp /lib64/qemu/* lib64/qemu

    # Copy firmware
    cp -r /usr/share/qemu/* usr/share/qemu

    # Copy bios
    cp /usr/share/seabios/* usr/share/bios
    cp /usr/share/seavgabios/* usr/share/bios

    # Copy firmware
    cp -r /usr/share/ipxe/* usr/share/ipxe
    cp -r /usr/share/ipxe.efi/* usr/share/ipxe.efi

    # This is needed for /bin/sh, required to call popen
    cp /lib64/libtinfo.so.6 lib64/libtinfo.so.6

    MODPROBE_LIBS=$(ldd /usr/sbin/modprobe | sed 's/.*=>//' | sed 's/(.*)//' | awk 'NR !=1 { print substr($0, 9) }' | xargs)

    echo "Copying ${MODPROBE_LIBS} from system to OS."
    for LIB in ${MODPROBE_LIBS}
    do
        cp "/lib64/${LIB}" "lib64/${LIB}"
    done


    LS_LIBS=$(ldd /bin/ls | sed 's/.*=>//' | sed 's/(.*)//' | awk 'NR !=1 { print substr($0, 9) }' | xargs)

    echo "Copying ${LS_LIBS} from system to OS."
    for LIB in ${LS_LIBS}
    do
        cp "/lib64/${LIB}" "lib64/${LIB}"
    done

    cp /usr/bin/qemu-system-x86_64 bin/qemu-system-x86_64
    cp /bin/ls bin/ls
    cp /bin/sh bin/sh
    cp /bin/cat bin/cat
    cp /usr/sbin/modprobe bin/modprobe

    chmod +x bin/ls bin/qemu-system-x86_64 bin/sh

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