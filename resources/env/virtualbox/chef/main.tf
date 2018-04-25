resource "virtualbox_vm" "node" {
	count = "${var.count}"
	name = "${var.name}"
	image = "${var.imagedir}/${var.image}"
	url = "${var.url}"
	cpus = "${var.cpus}"
	memory = "${var.memory}"
	network_adapter {
		type = "bridged"
		host_interface = "${var.interface}"
	}
}
