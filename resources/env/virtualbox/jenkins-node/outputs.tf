output "IPAddr" {
  value = "${virtualbox_vm.node.*.network_adapter.0.ipv4_address}"
}
output "IPAddr_1" {
	value = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)}"
}
output "IPAddr_2" {
	value = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 2)}"
}
