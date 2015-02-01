#!/bin/sh -x

sfdisk --force /dev/sda <<EOF
# partition table of /dev/sda
unit: sectors

/dev/sda1 : start=  2048, size= 204800, Id=83
/dev/sda2 : start=  206848, size= , Id=83
/dev/sda3 : start=  0, size=  0, Id= 0
/dev/sda4 : start=  0, size=  0, Id= 0
EOF

# create filesystems
mkfs.ext2  -L boot /dev/sda1
mkfs.btrfs -L root /dev/sda2

# mount the partitions
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

# create the root subvolume & mount it
btrfs subvol create /mnt/@
mkdir -p /mnt/root
mount -o subvol=@ /dev/sda2 /mnt/root
