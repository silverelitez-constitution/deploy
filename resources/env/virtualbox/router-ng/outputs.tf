output "IPAddr" {
    # Get the IPv4 address of the bridged adapter (the 2nd one) on 'node-02'
    value = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 0)}"
}
output "IPAddr1" {
    # Get the IPv4 address of the bridged adapter (the 2nd one) on 'node-02'
    value = "${element(virtualbox_vm.node.*.network_adapter.1.ipv4_address, 1)}"
}
