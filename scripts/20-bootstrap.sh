#!/bin/sh -x
MIRROR="http://ftp.tku.edu.tw/Linux/ArchLinux"

# use a preferred mirror
echo "Server = ${MIRROR}/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

# update the pacman database
pacman -Syy

# base installation
pacstrap /mnt/root base

# install required packages
arch-chroot pacman -S --noconfirm \
  openssh \
  grub-bios \
  virtualbox-guest-utils-nox \
  sudo \
  zsh \
  docker \
  salt-zmq \
  python2-pygit2 \
  glusterfs \
  rpcbind

# create fstab
genfstab -p /mnt >> /mnt/root/etc/fstab

# install script
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
systemctl enable docker.service
systemctl enable sshd.service
systemctl enable rpcbind.socket
systemctl enable glusterd.service

passwd -l root

groupadd vagrant

useradd -m -g users -G vagrant vagrant

touch ~/.zshrc

echo "vagrant:vagrant" | chpasswd

echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10-vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10-vagrant
chmod 0440 /etc/sudoers.d/10-vagrant

install -o vagrant -g users /home/vagrant/.zshrc
install -d -o vagrant -g users -m 0700 /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys -fsSL \
  https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown vagrant:users /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys

cat > /etc/modules-load.d/virtualbox.conf <<CONF
vboxguest
vboxsf
vboxvideo
CONF

pacman -R reiserfsprogs xfsprogs pcmciautils pciutils man-pages bash
pacman -Scc --noconfirm
EOF

# run the install script
arch-chroot /mnt/root sh -c "bash -x /etc/pre.sh"
