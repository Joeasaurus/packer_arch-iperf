# Some pacman clean commands
arch-chroot /mnt/root /bin/bash -x <<'SHELL'
pacman -Scc --noconfirm
pacman -Rns --noconfirm $(pacman -Qtdq)
pacman -Rcnsu --noconfirm autoconf bison \
	xfsprogs lvm2 man-pages groff \
	pcmciautils gcc jfsutils make \
	automake nano man-db \
	thin-provisioning-tools \
	psmisc reiserfsprogs mdadm \
	flex
SHELL


# Remove some other junk!
# There are many more firmware dirs to remove
rm -rf \
  /mnt/root/var/cache/pacman/* \
  /mnt/root/var/cache/* \
  /mnt/root/var/games \
  /mnt/root/var/log/journal/* \
  /usr/lib/firmware/ti-connectivity \
  /usr/lib/firmware/iwlwifi-* \
  /usr/lib/firmware/isci \
  /usr/lib/firmware/3com

cat /dev/zero > /mnt/root/zero.fill
cat /dev/zero > /mnt/root/boot/zero.fill
rm -f /mnt/root/zero.fill
rm -f /mnt/root/boot/zero.fill

# unmount everything
umount /mnt/root/boot
umount /mnt/root

# ensure pending disk writes are complete
sync