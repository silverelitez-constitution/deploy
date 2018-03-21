deployer() {
  service=${1}; shift
  password=${1}; shift
  hosts=${@:-${service}}
  if [[ ${hosts} == "all" ]]; then
    echo "Deploying to all hosts. Press enter to continue..."
	read
	hosts="$(nmap 10.37.224.* -sn | grep 'scan report for ' | cut -d' ' -f5)"
  else
	mosts="${hosts}"
	hosts=$(echo "${mosts}" | sed 's/ /\n/g')
  fi
  oldIFS=${IFS}
  IFS=$'\n'
  for host in ${hosts}
  do
	declare "$(ssh -oBatchMode=yes ${host} cat /etc/os-release)"
	echo Host ID is ${ID}
	echo Deploying to ${host}...
    #ping -c1 ${host} >/dev/null && 
	cd ~/deploy && scp packages/${service}.sh ${host}:~/ && ssh -oBatchMode=yes ${host} "~/${service}.sh ${password} && rm ${service}.sh"
  done
  IFS=${oldIFS}
}


svc=${1}
deploy="shayne"
echo "New Service: ${svc}"
cd ~/deploy/resources/env/virtualbox
[ -d ${svc} ] || { cp -rv --preserve=links base $svc && cd $_ || exit 1; }
cat >main.tf << EOL
resource "virtualbox_vm" "node" {
	name = "${svc}"
	count = 1
	url = "https://github.com/vezzoni/vagrant-vboxes/releases/download/0.0.1/centos-7-x86_64.box"
	image = "./terraform.d/centos-7-x86_64.box"
	cpus = 4
	memory = "1024 mib",
	network_adapter {
		type = "bridged",
		host_interface = "p4p1",
	}
}
EOL
terraform init && terraform apply -auto-approve || exit 1
ip=$(terraform output | grep 'IPAddr =' | cut -d' ' -f3)
while ! sshpass -p vagrant ssh-copy-id root@${ip} 2>/dev/null; do
	sleep 1
done
scp -r /home/${deploy}/.ssh/ root@${ip}:~/${deploy}
ssh root@${ip} sudo sh -c "whoami;
useradd -m -G wheel ${deploy};
mkdir -p /home/${deploy}/.ssh
mv ~/${deploy}/* /home/${deploy}/.ssh/;
echo \"${deploy}        ALL=(ALL)       NOPASSWD: ALL\" > /etc/sudoers.d/${deploy}
chown ${deploy}. /home/${deploy} -R"
ssh ${ip} "echo ${svc} > hostname; sudo mv hostname /etc; sudo reboot"
sleep 5
while ! ssh ${ip} whoami 2>/dev/null; do
	sleep 1
done
deployer provisioner $(cat ~/pw) ${svc}
deployer ${svc} $(cat ~/pw) 
#10.37.224.192