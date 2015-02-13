sfdisk -u S --force /dev/sda <<EOF
# partition table of /dev/sda

/dev/sda1 : start=64,size=409600,Id=83,bootable
/dev/sda2 : start=409664,size=,Id=83
EOF

# create filesystems & mount them
mkfs.ext2  -L boot /dev/sda1
mkfs.ext4 -L root /dev/sda2

mkdir -p /mnt/root
mount /dev/sda2 /mnt/root
mkdir /mnt/root/boot
mount /dev/sda1 /mnt/root/boot
