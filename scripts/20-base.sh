cat > /etc/pacman.d/mirrorlist <<'ENDOFLIST'
##
## Arch Linux repository mirrorlist
## Sorted by mirror score from mirror status page
## Generated on 2015-02-11
##

## Score: 0.8, United Kingdom
Server = http://mirror.bytemark.co.uk/archlinux/$repo/os/$arch
## Score: 0.9, United Kingdom
Server = http://archlinux.mirrors.uk2.net/$repo/os/$arch
## Score: 1.1, United Kingdom
Server = http://mirror.cinosure.com/archlinux/$repo/os/$arch
## Score: 1.6, United Kingdom
Server = http://mirrors.manchester.m247.com/arch-linux/$repo/os/$arch
## Score: 4.3, United Kingdom
Server = http://www.mirrorservice.org/sites/ftp.archlinux.org/$repo/os/$arch
## Score: 4.7, United Kingdom
Server = http://arch.serverspace.co.uk/arch/$repo/os/$arch
ENDOFLIST

sed -i '18 i\
	XferCommand = /usr/bin/curl -C - --progress-bar -f %u > %o' /etc/pacman.conf

pacman -Syy
# -c to use the local cache, not the target
pacstrap -c /mnt/root base base-devel
cp -f /etc/pacman.d/mirrorlist /mnt/root/etc/pacman.d/mirrorlist

genfstab -L -p /mnt/root >> /mnt/root/etc/fstab
