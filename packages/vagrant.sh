#!/bin/bash

echo -n Check for sudo/root...
if [[ ${SUDO_USER} ]] || [[ ${USER} == 'root' ]]; then
  echo Success;
else
  echo "Failed for ${USER}"
  echo "Executing script as root..."
  sudo ${0} ${@} || exit 1
  exit
fi

export PATH="${PATH}:/usr/local/go/bin"

cd /usr/src
wget -nc "https://releases.hashicorp.com/terraform/0.11.4/terraform_0.11.4_linux_amd64.zip" -O terraform.zip
unzip terraform.zip -d /usr/local/bin && rm terraform.zip || exit 1

cd
yum update -y
sudo yum install jq awscli unzip git kernel-devel kernel-devel-3.10.0-693.17.1.el7.x86_64 gcc make perl -y

version=$(curl https://download.virtualbox.org/virtualbox/LATEST.TXT)
wget https://download.virtualbox.org/virtualbox/${version}/Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack
rpmfile="$(wget -r -np -nc https://download.virtualbox.org/virtualbox/${version}/ -A VirtualBox*${version}*_el7-1.x86_64.rpm 2>&1 | grep 'download.virtualbox.org/virtualbox/' | grep '\.rpm' | tail -n1 | cut -d"‘" -f2 | cut -d'’' -f1)"

IFS=$'\n'
for vm in $(sudo -u vboxmanager vboxmanage list vms | cut -f2 -d'"')
do
	echo "Pausing ${vm}..."
	sudo -u vboxmanager VBoxManage controlvm "${vm}" pause >/dev/null &
	sleep 1
done

echo -n "Waiting for virtualbox to exit"
while ps aux | grep vboxman | grep virtualbox | grep -v grep
do
	echo -n '.'
	sleep 1
done
echo 
echo "Waiting for VBoxSVC to terminate..."

while ps aux | grep VBoxSVC | grep -v grep
do
	echo -n '.'
	killall -9 VBoxSVC
	sleep 0.5
done

sudo yum install -y ${rpmfile} && rm ${rpmfile}
sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack --replace --accept-license=56be48f923303c8cababb0bb4c478284b688ed23f16d775d729b89a2e8e5f9eb && rm Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack

yum install -y https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.rpm
curl https://dl.google.com/go/go1.10.linux-amd64.tar.gz | tar -C /usr/local -zx
go get github.com/ccll/terraform-provider-virtualbox
#vagrant up
