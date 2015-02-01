#!/bin/bash -x

arch-chroot /mnt/root pacman -S --noconfirm \
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
