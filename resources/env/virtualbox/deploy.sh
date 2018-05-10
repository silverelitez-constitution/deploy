#!/bin/bash
echo $@
service=${1}; shift
node=${1}; shift
dir=${1}; shift
count=${1};shift
packages=${@}; shift
svc=${service}

cd "${dir}"

deployer() {
	package=${1}; shift
	password=${1}; shift

	# if no host is specified then the host is the package name
	hosts=${@:-${package}}
	oldIFS=${IFS}
	IFS=$'\n'
	for host in ${hosts}
	do
    eval "$(ssh -oBatchMode=yes ${host} cat /etc/os-release)"
    echo Host ID is ${ID}
    echo Package is ${package}
    echo Service is ${service}
    echo Password length is ${#password}
    echo Deploying to ${host}...
    ssh -oBatchMode=yes ${host} "realm=\$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2 | cut -d. -f1)
      curl -s https://raw.githubusercontent.com/silverelitez-\${realm}/deploy/master/scripts/deployer.sh > ./deployer.sh
      chmod +x ./deployer.sh; sudo ./deployer.sh ${password} ${package} && rm ./deployer.sh"
	done
	IFS=${oldIFS}
}

IPAddr=$(terraform output -json IPAddr | jq ".value[${node}]")
[ "${count}" != '1' ] && hostname="${service}-$((${node}+1))" || hostname="${service}"
if [ ! "${IPAddr}" ]; then errmsg 1 "Could not determine IP address. Did resources apply?"; output="main_menu"; return; fi
dialog --infobox "${count} IP: ${IPAddr} Hostname: ${hostname}" 0 0
sleep 1
ip="$(echo ${IPAddr} | sed 's/\"//g')"
svc=${service}
#deploy="vboxmanager"
deploy="shayne"
ssh-keygen -R "${ip}"
dialog --infobox "New Service: ${svc}" 0 0

if ! ssh ${hostname} whoami >/dev/null 2>&1; then
  dialog --title ${hostname} --infobox "Waiting for ${ip} to accept default password..." 0 0
  while ! sshpass -p vagrant ssh-copy-id root@${ip} > /dev/null 2>&1 ; do
    sleep 0.3
  done
  dialog --title ${hostname} --infobox "Setting up ssh keys..." 0 0
  scp -r /home/${deploy}/.ssh/ root@${ip}:~/${deploy} 2>&1 | dialog --progressbox "Setting up ssh keys..." 15 80
  ssh root@${ip} sudo sh -c "whoami;
    useradd -m -G wheel ${deploy};
    mkdir -p /home/${deploy}/.ssh
    mv ~/${deploy}/* /home/${deploy}/.ssh/;
    echo \"${deploy}        ALL=(ALL)       NOPASSWD: ALL\" > /etc/sudoers.d/${deploy}
    chown ${deploy}. /home/${deploy} -R" 2>&1 | dialog --progressbox "Setting up remote users..." 15 80
  ssh ${ip} "source /etc/os-release; cd; [ \${ID} == 'gentoo' ] && { sudo sed 's/localhost/${hostname}/g' /etc/conf.d/hostname -i; } || { echo ${hostname} > ~/hostname; sudo mv ~/hostname /etc; }; sudo reboot;"  2>&1 | dialog --progressbox "Setting hostname and rebooting..." 15 80
  dialog --infobox "Rebooting ${hostname}..." 0 0
  sleep 5
  ssh-keygen -R ${hostname}
  dialog --infobox "Waiting for ${hostname}..." 0 0
  while ! ssh ${hostname} whoami >/dev/null 2>&1; do
    sleep 0.3
  done
fi

#deployer provisioner $(cat ~/pw) ${hostname} 2>&1 | dialog --progressbox "Provisioning ${hostname}..." 25 100
for package in "provisioner" ${packages}; do
  deployer ${package} $(cat ~/pw) ${hostname} 2>&1 | tee "${package}.log" | dialog --progressbox "Spinning up ${hostname} for ${svc}. Installing ${package}..." 25 100
done
