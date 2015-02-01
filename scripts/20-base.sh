#!/bin/bash -x
MIRROR="http://ftp.tku.edu.tw/Linux/ArchLinux"

echo "Server = ${MIRROR}/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

pacman -Syy
pacstrap /mnt/root base
genfstab -p /mnt >> /mnt/root/etc/fstab
