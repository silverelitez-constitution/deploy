
resource "virtualbox_vm" "node" {

    count = 2

    name = "${format("node-%02d", count.index+1)}"

    url = "https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/14.04/providers/virtualbox.box"

    image = "./virtualbox-ubuntu.box"

    cpus = 2

    memory = "512 mib",

    user_data = "${file("user_data")}"



    network_adapter {

        type = "bridged",

        host_interface = "en0",


    }



}
