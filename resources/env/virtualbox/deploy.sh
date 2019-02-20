#!/bin/bash
echo $@
dir=${1}; shift
cd "${dir}"
source terraform.tfvars
node=${1}; shift
service=${1}; shift
count=${1}; shift
packages=${@}; shift
svc=${service}

dialog() { command dialog --ascii-lines --backtitle "SilverElitez Systems | Deployer" "${@}"; }

# Save current variables to file
save() {
	dialog --infobox "Preparing files..." 3 34
	# Get list of required variables
	vars=$(cat terraform.tfvars.default | cut -d'=' -f1)
	# Clean the slate
	rm terraform.tfvars
	# Set variables and write tfvars file with new values
	#[ "${count}" -gt "1" ] && fname="${name}-\${count.index+1}" || fname="${name}"
	[ "${cpus}" == 'auto' ] && { dialog --infobox "Autodetecting cpus..." 3 34; cpus=$(grep -e '^processor' /proc/cpuinfo|wc -l); }
	[ "${disk}" == 'auto' ] && disk=""
	[ "${interface}" == 'auto' ] && interface="$(route | grep '^default' | grep -o '[^ ]*$'| head -n1)"
	dialog --infobox "Writing terraform data..." 3 34
	#name="${fname}"
	for variable in ${vars}
	do
		declare ${variable}="$(echo ${!variable})"
		dialog --infobox "${variable}=\"${!variable}\"" 3 34
		echo "${variable}=\"${!variable}\"" >> terraform.tfvars
	done
}

deployer() {
	package=${1}; shift
	password=${1}; shift

	# if no host is specified then the host is the package name
	hosts=${@:-${package}}
	oldIFS=${IFS}
	IFS=$'\n'
	for host in ${hosts}
	do
    eval "$(ssh -oBatchMode=yes ${username}@${host} cat /etc/os-release)"
    echo Host ID is ${ID}
    echo Package is ${package}
    echo Service is ${service}
    echo Password length is ${#password}
    echo Deployment username is ${username}
    echo Deploying to ${host}...
    ssh -oBatchMode=yes "${username}@${host}" "realm=\$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2 | cut -d. -f1)
      curl -s https://raw.githubusercontent.com/silverelitez-\${realm}/deploy/master/scripts/deployer.sh > ./deployer.sh
      chmod +x ./deployer.sh; sudo ./deployer.sh ${password} ${package} && rm ./deployer.sh"
	done
	IFS=${oldIFS}
}

IPAddr=$(terraform output -json IPAddr | jq ".value[${node}]")

[ "${count}" != '1' ] && hostname="${service}-$((${node}+1))" || hostname="${service}"
[ "${IPAddr}" ] || ( errmsg 1 "Could not determine IP address. Did resources apply?"; output="main_menu"; return )
dialog --infobox "${count} IP: ${IPAddr} Hostname: ${hostname}" 0 0
sleep 1
ip="$(echo ${IPAddr} | sed 's/\"//g')"
svc=${service}
#deploy="vboxmanager"
deploy="shayne"
ssh-keygen -R "${ip}"
dialog --infobox "New Service: ${svc}" 0 0

if ! ssh ${username}@${hostname} whoami >/dev/null 2>&1; then
  unset username
  dialog --title ${hostname} --infobox "Waiting for ${ip} to accept default password..." 0 0
  while [ ! "${username}" ];
  do
    for user in vagrant root
    do
      sshpass -p vagrant ssh-copy-id -f "${user}@${ip}" >/dev/null 2>&1 && username="${user}"
    done
  done
  save
  dialog --title ${hostname} --infobox "Setting up ssh keys for ${deploy} via ${username}..." 0 0
  sleep 1
  scp -r /home/${deploy}/.ssh/ "${username}@${ip}:~/${deploy}" 2>&1 | dialog --progressbox "Setting up ssh keys..." 15 80
  ssh "${username}@${ip}" sudo sh -c "whoami;
    sudo groupadd wheel;
    sudo mkdir -p /etc/sudoers.d;
    sudo useradd -s /bin/bash -m -G wheel ${deploy};
    sudo mkdir -p /home/${deploy}/.ssh;
    sudo mv ~/${deploy}/* /home/${deploy}/.ssh/;
    sudo echo \"${deploy}        ALL=(ALL)       NOPASSWD: ALL\" > ~/${deploy}.sudoers && sudo mv ~/${deploy}.sudoers /etc/sudoers.d/${deploy};
    echo "Fixing sudoers.d ownership..."
    sudo chown root.root /etc/sudoers.d/${deploy};
    sudo chown ${deploy}. /home/${deploy} -R;" 2>&1 | dialog --progressbox "Setting up remote users..." 15 80
    #echo ENTER; read
  ssh "${username}@${ip}" "source /etc/os-release; cd; [ \${ID} == 'gentoo' ] && { sudo sed 's/localhost/${hostname}/g' /etc/conf.d/hostname -i; } || { echo ${hostname} > ~/hostname; sudo mv ~/hostname /etc; }; sudo reboot;"  2>&1 | dialog --progressbox "Setting hostname and rebooting..." 15 80
  dialog --infobox "Rebooting ${hostname}..." 0 0
  # we don't wanna hop back on a terminating host!! give it a bit to kill sshd
  sleep 5
  ssh-keygen -R ${hostname}
  dialog --infobox "Waiting for ${hostname}..." 0 0
  while ! ssh ${hostname} whoami >/dev/null 2>&1; do
    sleep 0.3
  done
fi

#deployer provisioner $(cat ~/pw) ${hostname} 2>&1 | dialog --progressbox "Provisioning ${hostname}..." 25 100
for package in "provisioner" ${packages}; do
  deployer ${package} $(cat ~/pw) ${hostname} 2>&1 | tee "${package}.log" | dialog --progressbox "Spinning up ${hostname} for ${svc}. Installing ${package}..." 25 80
done
