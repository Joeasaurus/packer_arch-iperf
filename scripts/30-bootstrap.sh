#!/bin/bash -x

# install script
arch-chroot /mnt/root /bin/bash -x <<SHELL
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

echo "vagrant:vagrant" | chpasswd

echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10-vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10-vagrant
chmod 0440 /etc/sudoers.d/10-vagrant

touch /home/vagrant/.zshrc /root/.zshrc

install -d -o vagrant -g users -m 0700 /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys -fsSL \
  https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown vagrant:users /home/vagrant/.ssh/authorized_keys /home/vagrant/.zshrc
chmod 0600 /home/vagrant/.ssh/authorized_keys
chmod 0640 /home/vagrant/.zshrc

chsh -s $(which zsh) root
chsh -s $(which zsh) vagrant

cat > /etc/modules-load.d/virtualbox.conf <<CONF
vboxguest
vboxsf
vboxvideo
CONF

pacman -Rcns --noconfirm reiserfsprogs xfsprogs pcmciautils pciutils man-pages
pacman -Scc --noconfirm
SHELL
