resource "virtualbox_vm" "node" {
	name = "puppet"
	count = 1
	url = "https://github.com/vezzoni/vagrant-vboxes/releases/download/0.0.1/centos-7-x86_64.box"
	image = "./terraform.d/centos-7-x86_64.box"
	cpus = 4
	memory = "1024 mib",
	network_adapter {
		type = "bridged",
		host_interface = "p4p1",
	}
}
