# Basic system settings
arch-chroot /mnt/root /bin/bash -x <<SYS
echo "archlinux" > /etc/hostname

ln -s /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc --utc

echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

sed -i 's/^\(HOOKS.*\)fsck/\1/' /etc/mkinitcpio.conf
mkinitcpio -p linux
SYS

# Grub
arch-chroot /mnt/root /bin/bash -x <<'GRUB'
modprobe dm-mod

grub-install --recheck /dev/sda
sed -i -r 's/(GRUB_TIMEOUT=).*/\10/g' /etc/default/grub
sed -i -r 's/(GRUB_CMDLINE_LINUX_DEFAULT="[^"]+)"$/\1 libahci.ignore_sss=1"/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
GRUB

# Users
arch-chroot /mnt/root /bin/bash -x <<'USER'
groupadd vagrant
useradd -m -g users -G vagrant,vboxsf vagrant

echo "root:$(openssl passwd -crypt 'vagrant')" | chpasswd
echo "vagrant:$(openssl passwd -crypt 'vagrant')" | chpasswd
USER

# SSH
arch-chroot /mnt/root /bin/bash -x <<'SSH'
sed -i '$ i\
	UseDNS no' /etc/ssh/sshd_config
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10-vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10-vagrant
chmod 0440 /etc/sudoers.d/10-vagrant
install -d -o vagrant -g users -m 0700 /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys -fsSL \
  https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown vagrant:users /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
SSH

# Modules
cat > /mnt/root/etc/modules-load.d/virtualbox.conf <<MODULES
vboxguest
vboxsf
vboxvideo
MODULES

# iperf3
arch-chroot /mnt/root /bin/bash -x <<IPERF
mkdir -p /tmp/iperf3 && \
	cd /tmp/iperf3 && \
	curl -o iperf.tgz "http://downloads.es.net/pub/iperf/${IPERF_VERSION}.tar.gz" && \
	tar zxvf iperf.tgz && \
	cd "${IPERF_VERSION}" && \
	./configure && make && make install && \
	cd && rm -rf /tmp/iperf3
IPERF

# Services
cat > /mnt/root/etc/systemd/system/iperf3.service <<IPERF_SERVICE
[Unit]
Description=iperf3 Server

[Service]
ExecStart=/usr/local/bin/iperf3 -s -D
Type=forking

[Install]
WantedBy=multi-user.target
IPERF_SERVICE

arch-chroot /mnt/root /bin/bash -x <<SERVICES
systemctl enable dhcpcd.service
systemctl enable sshd.service
systemctl enable iperf3.service
SERVICES

