#!/bin/sh -x

# base installation
pacstrap /mnt/rootfs base

# create fstab
genfstab -U -p /mnt >> /mnt/rootfs/etc/fstab

# add dropbear unit files
cat > /mnt/rootfs/etc/systemd/system/dropbear.socket <<EOF
[Unit]
Conflicts=dropbear.service

[Socket]
ListenStream=22
Accept=yes

[Install]
WantedBy=sockets.target
Also=dropbear-keygen.service
EOF

cat > /mnt/rootfs/etc/systemd/system/dropbear@.service <<EOF
[Unit]
Description=SSH Per-Connection Server
Wants=dropbear-keygen.service
After=syslog.target dropbear-keygen.service

[Service]
EnvironmentFile=-/etc/default/dropbear
ExecStart=-/usr/bin/dropbear -i -r /etc/dropbear/dropbear_rsa_host_key $DROPBEAR_OPTS
ExecReload=/bin/kill -HUP $MAINPID
StandardInput=socket
KillMode=process
EOF

cat > /mnt/rootfs/etc/systemd/system/dropbear-keygen.service <<EOF
[Unit]
Description=SSH Key Generation
ConditionPathExists=|!/etc/dropbear/dropbear_rsa_host_key

[Service]
Type=oneshot
ExecStart=/usr/bin/dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
RemainAfterExit=yes
EOF

cat > /mnt/rootfs/setup.sh <<EOF
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

ln -s /etc/systemd/system/dropbear-keygen.service /etc/systemd/system/multi-user.target.wants/dropbear-keygen.service

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
umount /mnt/rootfs
umount /mnt
systemctl reboot
