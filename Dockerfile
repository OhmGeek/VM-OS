FROM debian:latest

# Install Qemu from the Debian package manager. 
RUN apt-get -y install qemu-system