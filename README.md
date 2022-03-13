# VM-OS
A linux distribution that runs QEMU as pid-1

The goal: a single OS for running other OSes (imagine: a modern system booting old OS installs).


# You will need:
- glibc-static installed on your OS (to statically compile our init)
- glib2-static installed on your OS (for qemu)
- Some time/patience
- Currently: a x86_64 system running Fedora (lots of reliance on the host OS). This might work on other distros, but might not.
