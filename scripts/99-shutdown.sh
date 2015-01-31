#!/bin/sh -x

# unmount everything
umount /mnt/root
umount /mnt/boot
umount /mnt

# ensure pending disk writes are complete
sync
