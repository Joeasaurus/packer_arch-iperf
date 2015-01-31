#!/bin/sh -x

echo "Server = http://ftp.tku.edu.tw/Linux/ArchLinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
pacman -Syy

# base installation
pacstrap /mnt/root base openssh grub-bios virtualbox-guest-modules

# create fstab
genfstab -p /mnt >> /mnt/root/etc/fstab

cat > /mnt/root/etc/pre.sh <<EOF
echo "archlinux" > /etc/hostname
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

ln -s /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc --utc

locale-gen

sed -i 's/^\(HOOKS.*\)fsck/\1/' /etc/mkinitcpio.conf
mkinitcpio -p linux

modprobe dm-mod

grub-install --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable dhcpcd.service
systemctl enable sshd.service

groupadd vagrant

useradd -m -g users -G vagrant vagrant

echo "root:archlinux" | chpasswd
echo "vagrant:vagrant" | chpasswd

mkdir -p /etc/sudoers.d
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10-vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10-vagrant
chmod 0440 /etc/sudoers.d/10-vagrant

install -d -o vagrant -g users -m 0700 /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys -fsSL http://git.io/FKMe
chown vagrant:users /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys

cat > /etc/modules-load.d/virtualbox.conf <<CONF
vboxguest
vboxsf
vboxvideo
CONF

pacman -Scc --noconfirm
EOF

arch-chroot /mnt/root sh -c "bash -x /etc/pre.sh"
