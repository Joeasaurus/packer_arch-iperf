arch-chroot /mnt/root pacman-db-upgrade

arch-chroot /mnt/root pacman -S --noconfirm \
  virtualbox-guest-utils-nox \
  openssh \
  grub-bios \
  sudo \
  rpcbind \
  net-tools \
  wget
