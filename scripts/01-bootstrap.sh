#!/bin/sh -x

# base installation
pacstrap /mnt/rootfs base

# create fstab
genfstab -U -p /mnt >> /mnt/etc/fstab

# add dropbear unit files
mv /tmp/dropbear.socket /mnt/etc/systemd/system/
mv /tmp/dropbear@.service /mnt/etc/systemd/system/
mv /tmp/dropbearkey.service /mnt/etc/systemd/system/

cat > /mnt/rootfs/usr/local/bin/setup.sh <<EOF
#!/bin/sh -x

echo 'archlinux' > /etc/hostname
echo 'KEYMAP=us' > /etc/vconsole.conf
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

hwclock --systohc --utc

locale-gen

mkinitcpio -p linux

pacman -S --noconfirm dropbear btrfs-progs

# pacman -S --noconfirm syslinux
# syslinux-install_update -i -a -m
# sed -i 's/sda3/sda1/' /boot/syslinux/syslinux.cfg
# sed -i 's/TIMEOUT 50/TIMEOUT 10/' /boot/syslinux/syslinux.cfg

echo "root:`openssl passwd -crypt 'vagrant'`" | chpasswd

ln -s /usr/lib/systemd/system/dhcpcd.service /etc/systemd/system/multi-user.target.wants/dhcpcd.service

ln -s /etc/systemd/system/dropbear.socket /etc/systemd/system/socket.target.wants/dropbear.socket

ln -s /etc/systemd/system/dropbearkey.service /etc/systemd/system/multi-user.target.wants/dropbearkey.service

groupadd vagrant

useradd -p `openssl passwd -crypt 'vagrant'` -m -g users -G vagrant,vboxsf vagrant

echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10-vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10-vagrant
chmod 0440 /etc/sudoers.d/10-vagrant

install -d -o vagrant -g users -m 0700 /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys -fsSL http://git.io/FKMe
chown vagrant:users /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys

pacman -Scc --noconfirm
EOF

arch-chroot /mnt/rootfs /bin/sh /setup.sh
rm /mnt/rootfs/setup.sh
umount /mnt/rootfs/home
umount /mnt/rootfs
umount /mnt
systemctl reboot
