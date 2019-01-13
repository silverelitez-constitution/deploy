output "IPAddr" {
  value = "${virtualbox_vm.node.*.network_adapter.0.ipv4_address}"
}
