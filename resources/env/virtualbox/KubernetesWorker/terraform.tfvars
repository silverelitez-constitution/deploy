provider="virtualbox"
count="2"
memory="2.0 gib"
os="4"
interface="p4p1"
cpus="4"
image="vagrant-centos-7.2.box"
url="https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.2/vagrant-centos-7.2.box"
imagedir="./terraform.d/images/"
packages="kubernetes"
username="root"
name="KubernetesWorker"
service="KubernetesWorker"