resource "virtualbox_vm" "node" {
	count = "${var.count}"
	name = "${format("${var.name}-%02d", count.index + 1)}"
	image = "${var.imagedir}/${var.image}"
	url = "${var.url}"
	cpus = "${var.cpus}"
	memory = "${var.memory}"
	network_adapter {
		type = "bridged"
		host_interface = "${var.interface}"
	}
}
