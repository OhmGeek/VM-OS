#!/bin/bash

apt-get update
# Install tools to build the linux kernel on Debian.
apt-get -y install make gcc binutils cpio build-essential linux-source bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev dwarves bison


# Build options
LINUX_BUILD_TYPE="defconfig"
LINUX_BUILD_PARALLEISM=$(nproc)
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

function copy_linked_libs() {
    LIBS=$(ldd $1 | sed 's/.*=>//' | sed 's/(.*)//' |  awk 'NR !=1 { print $0 }' | xargs)

    echo "Copying ${LIBS} from system to OS."
    for LIB in ${LIBS}
    do
        # Create a directory if it doesn't exist.
        mkdir -p $(dirname "./${LIB}")
        # Then copy into the fakeroot.
        cp -f "${LIB}" ".${LIB}"
    done

}

function build_linux() {
    apt-get update
    apt-get -y install gmake
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
    apt-get -y install qemu-system
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
    mkdir -p usr/lib/x86_64-linux-gnu
    mkdir root

    copy_linked_libs "/usr/bin/qemu-system-x86_64"

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

    # Copy drivers for vga
    cp /lib64/libgbm.so.1 lib64/libgbm.so.1 
    cp /lib64/libgtk-3.so.0 lib64/libgtk-3.so.0
    cp /lib64/libSDL2-2.0.so.0 lib64/libSDL2-2.0.so.0 
    cp /lib64/libepoxy.so.0 lib64/libepoxy.so.0
    cp /lib64/libgdk-3.so.0 lib64/libgdk-3.so.0
    cp /lib64/libSDL2_image-2.0.so.0 lib64/libSDL2_image-2.0.so.0
    cp /lib64/libdrm.so.2 lib64/libdrm.so.2 
    cp /lib64/libcairo.so.2 lib64/libcairo.so.2
    cp /lib64/libX11.so.6 lib64/libX11.so.6
    cp /lib64/libtiff.so.5 lib64/libtiff.so.5 
    cp /lib64/libgdk_pixbuf-2.0.so.0 lib64/libgdk_pixbuf-2.0.so.0 
    cp /lib64/libexpat.so.1 lib64/libexpat.so.1 
    cp /lib64/libvte-2.91.so.0 lib64/libvte-2.91.so.0 
    cp /lib64/libwebp.so.7 lib64/libwebp.so.7 
    cp /lib64/libpangocairo-1.0.so.0 lib64/libpangocairo-1.0.so.0 
    cp /lib64/libxcb.so.1 lib64/libxcb.so.1
    cp /lib64/libjbig.so.2.1 lib64/libjbig.so.2.1
    cp /lib64/libpango-1.0.so.0 lib64/libpango-1.0.so.0
    cp /lib64/libharfbuzz.so.0 lib64/libharfbuzz.so.0 
    cp /lib64/libXau.so.6 lib64/libXau.so.6 
    cp /lib64/libpangoft2-1.0.so.0 lib64/libpangoft2-1.0.so.0 
    cp /lib64/libfontconfig.so.1 lib64/libfontconfig.so.1 
    cp /lib64/libfribidi.so.0 lib64/libfribidi.so.0 
    cp /lib64/libcairo* lib64

    # This is needed for /bin/sh, required to call popen
    cp /lib64/libtinfo.so.6 lib64/libtinfo.so.6

    
    # Copy dependencies for binaries.
    copy_linked_libs "/usr/sbin/modprobe"
    copy_linked_libs "/bin/ls"
    copy_linked_libs "/usr/bin/chmod"
    copy_linked_libs "/usr/sbin/useradd"
    copy_linked_libs "/usr/sbin/usermod"
    copy_linked_libs "/usr/sbin/groupadd"


    mkdir -p usr/bin
    cp /usr/bin/chmod bin/chmod
    cp /usr/bin/qemu-system-x86_64 bin/qemu-system-x86_64
    cp /bin/ls bin/ls
    cp /bin/sh bin/sh
    cp /bin/cat bin/cat
    cp /usr/sbin/modprobe bin/modprobe
    cp /usr/sbin/groupadd bin/groupadd
    cp /usr/sbin/useradd bin/useradd
    cp /usr/sbin/usermod bin/usermod
    cp /usr/bin/id usr/bin/id
    cp /bin/cat bin/cat
    cp /usr/bin/tty bin/tty

    chmod +x bin/ls bin/qemu-system-x86_64 bin/sh

    # Copy images
    mkdir -p opt/images
    cp ../images/* opt/images


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
