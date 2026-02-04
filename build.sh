#!/bin/bash
sudo lb clean
sudo lb config --bootloaders grub-pc,grub-efi --debian-installer false --apt-indices false --apt-recommends false --debootstrap-options "--variant=minbase"
sudo lb build
