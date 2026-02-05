#!/bin/bash
sudo lb clean
sudo lb config --bootloaders grub-pc,grub-efi --debian-installer false --apt-indices false --apt-recommends false --debootstrap-options "--variant=minbase"
sudo lb build
cp "live-image-amd64.hybrid.iso" "/tmp/SHOS-amd64.iso"
sudo lb clean
echo "ISO coppied to /tmp/SHOS-amd64.iso"
