Packer - Arch-Iperf
===========

Notes
-----
If you are building on an ext4 filesystem, use this in the template.json:
[ "storagectl", "{{.Name}}", "--name", "SATA Controller", "--hostiocache", "on" ]

This repository provides a [Packer](http://www.packer.io/) template for generating
a [Vagrant](http://www.vagrantup.com/) base box with [Arch Linux](https://www.archlinux.org/)
installed. The installation starts an iperf3 server at boot time for ethernet testing. It currently
only supports the Virtualbox provider.

Thanks to those before me who did most of the work, I just forked and tweaked a few things.

Overview
--------

My main goal is to get iperf3 running at boot time in as small a box as possible. I haven't got
very far with this, but we're heading in the right direction. Here are the specs I've set by default:

* 64-bit
* 1 GB disk
* 512 MB memory
* 2 CPUs
* No swap
* Iperf3 (kinda required!)

The installation script follows the
[official installation guide](https://wiki.archlinux.org/index.php/Installation_Guide)
pretty closely, with a few tweaks to ensure functionality within a VM.

Usage
-----

### VirtualBox Provider

Assuming that you already have Packer,
[VirtualBox](https://www.virtualbox.org/), and Vagrant installed, you
should be good to clone this repo and go:

    $ git clone https://github.com/Joeasaurus/packer_arch-iperf.git
    $ cd packer_arch-iperf
    $ packer build arch-template.json

Then you can import the generated box into Vagrant:

    $ vagrant box add arch-iperf.box

### VMware Provider

Assuming that you already have Packer,
[VMware Fusion](https://www.vmware.com/products/fusion/) (or
[VMware Workstation](https://www.vmware.com/products/workstation/)), and
Vagrant with the VMware provider installed, you should be good to clone
this repo and go:

    $ git clone https://github.com/elasticdog/packer-arch.git
    $ cd packer-arch/
    $ packer build -only=vmware-iso arch-template.json

Then you can import the generated box into Vagrant:

    $ vagrant box add arch-iperf arch-iperf.box

I have, however, included a Vagrantfile that's ready to use. Simply edit the settings
at the top so they suit your environment and run:

    $ vagrant up

I have also included a basic metadata.json so you can start versioning this box yourself
and hosting them on your own webserver!

Known Issues
------------

### Vagrant Provisioners

The box purposefully does not include Puppet or Chef for automatic Vagrant
provisioning. My intention was to duplicate a DigitalOcean VPS and
furthermore use the VM for testing [Ansible](http://www.ansibleworks.com/)
playbooks for configuration management.

License
-------

Packer Arch is provided under the terms of the
[ISC License](https://en.wikipedia.org/wiki/ISC_license).

Copyright &copy; 2013&#8211;2014, [Aaron Bull Schaefer](mailto:aaron@elasticdog.com).
