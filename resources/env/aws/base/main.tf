provider "aws" {
  region     = "us-east-1"
}

resource "aws_instance" "web" {
	count = "${var.count}"
	name = "${format("${var.name}-%02d", count.index + 1)}"
	ami = "${var.ami}"
	cpus = "${var.cpus}"
	memory = "${var.memory}"
	network_adapter {
		type = "bridged"
		host_interface = "${var.interface}"
	}
}
