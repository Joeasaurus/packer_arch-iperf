INTERFACE = "en0: Ethernet"
IP_ADDR = "10.10.10.2"
BOX_URL = "http://localhost/jme/arch-iperf.box"

ENABLE_GUI = false

# This box has 512 MB by default
CUSTOM_RAM = false # 1024
# This box has 2 CPUs by default
CUSTOM_CPU = false # 4

# !! Don't edit below here !! #
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	config.vm.box = "arch-iperf"
	config.vm.box_url = BOX_URL

	# Bridged inf for using iperf on
	config.vm.network :public_network, ip: IP_ADDR, bridge: INTERFACE

	config.vm.provider :virtualbox do |vb|
		vb.gui = ENABLE_GUI

		if CUSTOM_RAM
			vb.memory = CUSTOM_RAM
		end

		if CUSTOM_CPU
			vb.cpus = CUSTOM_CPU
		end

		# This reduces the amount of time to boot (merginally)
		vb.customize ["modifyvm", :id, "--bioslogodisplaytime", "1"]
	end

	# Extra improvements
	config.vm.synced_folder '.', '/vagrant', disabled: true
end

