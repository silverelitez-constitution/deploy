resource "virtualbox_vm" "node" {
	name = "${var.name}"
	count = "${var.count}"
	url = "${var.url}"
	image = "${var.imagedir}/${var.image}"
	cpus = "${var.cpus}"
	memory = "${var.memory}",
	network_adapter {
		type = "bridged",
		host_interface = "${var.interface}",
	}
}
