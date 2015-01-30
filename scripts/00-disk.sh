#!/bin/sh -x
DISK="/dev/sda"

# wipe disk, and create partition table
sgdisk --zap ${DISK}
dd if=/dev/zero of=${DISK} bs=512 count=2048
wipefs --all ${DISK}
sgdisk --new=1:0:0 ${DISK}
sgdisk ${DISK} --attributes=1:set:2

# create & mount btrfs filesytem
mkfs.btrfs -f -L root ${DISK}1
mount ${DISK}1 /mnt

# create & mount subvolumes
btrfs subvol create /mnt/@
btrfs subvol create /mnt/@home
mkdir -p /mnt/rootfs
mount -o subvol=@ ${DISK}1 /mnt/rootfs
mkdir -p /mnt/rootfs/home
mount -o subvol=@home ${DISK}1 /mnt/rootfs/home
