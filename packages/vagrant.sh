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
sudo yum install -y https://download.virtualbox.org/virtualbox/5.2.6/VirtualBox-5.2-5.2.6_120293_el7-1.x86_64.rpm
yum install -y https://releases.hashicorp.com/vagrant/2.0.2/vagrant_2.0.2_x86_64.rpm
curl https://dl.google.com/go/go1.10.linux-amd64.tar.gz | tar -C /usr/local -zx
go get github.com/ccll/terraform-provider-virtualbox
#vagrant up
