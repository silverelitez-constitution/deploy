provider="virtualbox"
count="1"
memory="1.0 gib"
os="4"
interface="p4p1"
cpus="4"
image="vagrant-centos-7.2.box"
url="https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.2/vagrant-centos-7.2.box"
imagedir="./terraform.d/images/"
packages="docker s3fs-src"
username="root"
name="Rancher"
service="rancher"