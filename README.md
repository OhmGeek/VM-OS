# VM-OS
A linux distribution that runs QEMU as pid-1

The goal: a single OS for running other OSes (imagine: a modern system booting old OS installs).


## You will need:
- glibc-static installed on your OS (to statically compile our init)
- glib2-static installed on your OS (for qemu)
- qemu installed locally
- Some time/patience
- Currently: a x86_64 system running Fedora (lots of reliance on the host OS). This might work on other distros, but might not.

## How to use:
1. ./build.sh
   1. This will build the linux kernel (for X86_64)
   2. Will pull in qemu from the host machine (and all dependencies)
2. Copy a single ISO image (cd rom) into the images/ folder
3. Run ./run.sh:
   1. This will start qemu
   2. Sets up the basic OS structure
   3. Loads the ISO image from images/

## Limitations:
- No networking support added