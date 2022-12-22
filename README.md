# VM-OS
A linux distribution that runs QEMU as pid-1

The goal: a single OS for running other OSes (imagine: a modern system booting old OS installs).


## Requirements:
- Install QEMU system on your local machine.
- Ensure you have a bash shell.
- Install you have docker installed.


## How to run a build:

Copy an ISO image that you want to run, into the `images` directory of the repo.

Run `./sh.sh`, which creates a docker based build environment.

Within this build environment, run:

`/build/build.sh`

This will setup the base build environment, and extract the bzImage and initrd.img to the appropriate location.

To exit the build environment, simply run `exit`.

From your local system, you can then run the application by running:

`./run.sh`

This will boot up your VM-OS within QEMU on your local machine! this will run the image from the images/ directory.