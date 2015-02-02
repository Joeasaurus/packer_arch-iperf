# install script
arch-chroot /mnt/root /bin/bash -x <<SHELL
echo "archlinux" > /etc/hostname

ln -s /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

sed -i 's/^\(HOOKS.*\)fsck/\1/' /etc/mkinitcpio.conf
mkinitcpio -p linux

modprobe dm-mod

grub-install --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Add Docker TCP socket to listen on port 2375
curl -o /etc/systemd/system/docker-tcp.socket -fsSL http://git.io/bezo

# Add /etc/hosts file to point to salt master on the host machine
curl -o /etc/hosts -fsSL http://git.io/bezC

systemctl enable dhcpcd.service
systemctl enable docker.socket
systemctl enable docker-tcp.socket
systemctl enable sshd.socket
systemctl enable salt-minion.service

groupadd vagrant

useradd -m -g users -G vagrant,vboxsf,docker vagrant

echo "root:`openssl passwd -crypt '${PW}'`" | chpasswd
echo "vagrant:`openssl passwd -crypt 'vagrant'`" | chpasswd

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

chsh -s /usr/bin/fish root
chsh -s /usr/bin/fish vagrant

cat > /etc/modules-load.d/virtualbox.conf <<CONF
vboxguest
vboxsf
vboxvideo
CONF

pacman -Scc --noconfirm
SHELL
