# remove some things which may stick around
rm -rf \
  /mnt/root/var/cache/pacman/* \
  /mnt/root/var/cache/* \
  /mnt/root/var/games \
  /mnt/root/var/lib/docker/* \
  /mnt/root/var/lib/glusterd/* \
  /mnt/root/var/log/glusterfs/* \
  /mnt/root/var/log/journal/*

# unmount everything
umount /mnt/root
umount /mnt/boot
umount /mnt

# ensure pending disk writes are complete
sync
