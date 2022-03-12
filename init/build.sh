#!/usr/bin/bash

# Delete the binary if it already exists
rm init

# This just builds our init system, statically linked.
gcc -static-libgcc -o init main.c
