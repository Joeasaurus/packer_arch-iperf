build:
	packer build ./template.json
	vagrant box add --force --name archlinux ./archlinux.box
