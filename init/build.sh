#!/bin/bash

apt-get update
apt-get -y install gcc 

# Delete the binary if it already exists
rm init

# This just builds our init system, statically linked.
gcc -static -o init main.c
