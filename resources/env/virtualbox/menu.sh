#!/bin/bash

# Init
init() {
	# Optionally get service name from cmdline
	[ "${@}" ] && [ ! ${service} ] && service=${1}

	# Prepare working directory
	dialog --infobox "${service} | Preparing working directory..." 0 0
	cd ~/deploy/resources/env/virtualbox
	# See if service directory exists. If not, copy base files and insert service and name
	[ -d "${service}" ] || { cp -r --preserve=links base "${service}" && cd "${service}" && echo -e "name=\"${name}\"\nservice=\"${service}\"" >> terraform.tfvars.default ;} && cd "${service}"

	# Pull in current default values
	dialog --infobox "Initializing options..." 3 32
	[ -e "terraform.tfvars" ] && source terraform.tfvars || source terraform.tfvars.default

	# If the name is blank, match it with the service name
	name=${name:-${service}}
	[ ! "${packages}" ] && packages="${packages:-${service}}"

	# Refresh image list
	dialog --infobox "Refreshing list of VM images..." 0 0
	curl -s http://www.vagrantbox.es | grep -e '\.box' | cut -d'>' -f2 | cut -d'?' -f1 | grep -v "dropbox" | cut -d'<' -f1 > ./terraform.d/os.list
	# Parse list for variable values
	url=$(cat ./terraform.d/os.list | head -n${os} | tail -n1)
	image=$(cat ./terraform.d/os.list | head -n${os} | tail -n1 | rev | cut -d'/' -f1 | rev)
	# Fall into main loop
	dialog --infobox "Ready!" 0 0
	sleep 0.1
	output="main_menu"
}

# Main menu
main() {
	output=$(
		dialog --stdout --title "Service Configuration | $(pwd)" \
		--menu "Please choose setting to change:" 0 0 0 \
			s "Service - ${service}" \
			n "Name - ${name}" \
			i "Image - ${os}:${image}" \
			c "CPUs - ${cpus:-default}" \
			m "RAM - ${memory:-default}" \
			d "Disk Space - ${disk:-default}" \
			N "Networking - ${interface:-auto}" \
			z "Zone (beta) - ${zone:-default}" \
			P "Packages - ${packages:-none}" \
			e "Edit resource files" \
			x "Save service" \
			p "Save service and run Plan" \
			S "Save service and deploy" \
			A "Save and Apply" \
			E "Skip to Deployment (!!)" \
			T "Terraform Destroy" \
			X "Destroy service" \
			R "Refresh menu" \
			D "Save settings as default (beta)"
		)

	case $? in 
		0) case $output in
			i) image;;
			c) cpus;;
			m) memory;;
			N) networking;;
			d) disk;;
			s) services;;
			n) setname;;
			z) zone;;
			P) packages;;
			e) editor;;
			p) save; plan;;
			E) deploy;;
			A) save; apply;;
			T) terraform destroy --auto-approve | dialog --progressbox "Running terraform destroy..." 15 80;;
			X) destroy;;
			x) save;;
			R) init ${service};;
			S) save; apply; deploy;;
			?) echo wat;;
		esac
		;;
		1) exit 0
		;;
		255) echo ERR
		;;
	esac
}

# Image selection menu
image() {
	dialog --infobox "Loading list..." 3 20
	# 1 "Centos 7" $(if [ $os == "1" ]; then echo "on"; else echo off; fi) \
	ar=()
	i=0
	while read url; do
		i=$((${i}+1))
		image=$(echo ${url} | rev | cut -d'/' -f1 | rev)
		ar+=($i "${image}" $([ $i == ${os} ] && echo -n on || echo -n off))
	done < ./terraform.d/os.list
	output=$(dialog --stdout --title "Image list" \
		--radiolist "Please choose Image:" 0 0 0 "${ar[@]}"
		)
	os=${output:-1}
	url=$(cat ./terraform.d/os.list | head -n${os} | tail -n1)
	image=$(cat ./terraform.d/os.list | head -n${os} | tail -n1 | rev | cut -d'/' -f1 | rev)
	dialog --infobox "Image $os:\n${url}" 0 0
	sleep 1
}

# Ram selection menu
memory() {
	# Function to select current option
	c=0
	other() { [ "1" != ${c} ] && echo -n "${memory} - " ;}
	isChecked() { 
		if [ $memory == "${1}" ]; then echo -n on; declare c="1"; else echo -n off; fi
	}
	MEMORY=$(
		dialog --stdout --title "$output" \
		--radiolist "Please choose $output:" 0 0 0 \
			"64 mib" "64MB" $(isChecked "64 mib") \
			"128 mib" "128MB" $(isChecked "128 mib") \
			"256 mib" "256MB" $(isChecked "256 mib") \
			"512 mib" "512MB" $(isChecked "512 mib") \
			"1.0 gib" "1GB" $(isChecked "1.0 gib") \
			"2.0 gib" "2GB" $(isChecked "2.0 gib") \
			"4.0 gib" "4GB" $(isChecked "4.0 gib") \
			"8.0 gib" "8GB" $(isChecked "8.0 gib") \
			"16.0 gib" "16GB" $(isChecked "16.0 gib") \
			"32.0 gib" "32GB" $(isChecked "16.0 gib") \
			"64.0 gib" "64GB" $(isChecked "16.0 gib") \
			"128.0 gib" "128GB" $(isChecked "16.0 gib") \
			"256.0 gib" "256GB" $(isChecked "16.0 gib") \
			"other" "$([ ${c} == "0" ] && echo -n "${memory} - ";)Enter other value" $([ "1" != ${c} ] && echo -n on || echo -n off) 
		)
	[ "${MEMORY}" == "other" ] && MEMORY=$(dialog --stdout --inputbox "VM Memory:" 0 0 "${memory}")

	memory=${MEMORY:-${memory}}
}

# Dialog to change resource name
setname() {
	output=$(dialog --stdout --inputbox "Name:" 0 0 "${name}")
	name="${output:-${name}}"
}

# Define deployment zone
zone() {
	output=$(dialog --stdout --inputbox "Zone:" 0 0 "${zone}")
	zone="${output:-${zone}}"
}

# Networking managment function
networking() {
	output=$(dialog --stdout --inputbox "Network interface ('auto' to autodetect):" 0 0 "${interface}")
	interface="${output:-${interface}}"
}

# Display error messages
errmsg() { code="${1}"
	shift;
	message="${@}"
	dialog --title "Alert!" --msgbox "Error ${code}: ${message}" 0 0
}

# Resource File Editor
editor() {
	filename="$(dialog --stdout --fselect "$(pwd)/" 10 70)"
	case $? in
		0) dialog --infobox "Opening ${filename}..." 6 20;;
		1) output="main_menu"; return;;
		*) errmsg "${?}" "${code}" "${filename}"; editor;;
	esac
	data="$(dialog --stdout --editbox "${filename}" 0 0 2>&1 ;)"
	case $? in
		0) echo -e "${data}" > ${filename} && init;;
		1) editor;;
		*) errmsg "${data}"; editor;;
	esac
}

# Dialog to change cpu count
cpus() {
	output=$(dialog --stdout --inputbox "Number of CPUs ('auto' to autodetect):" 0 0 "${cpus}")
	[ ! "${output}" ] && cpus="auto"
	cpus="${output:-${cpus}}"
	output="main_menu"
}

# Dialog to change disk space
disk() {
	output=$(dialog --stdout --inputbox "Disk space ('auto' to autodetect):" 0 0 "${disk}")
	disk="${output:-${disk}}"
}

# Save current variables to file
save() {
	dialog --infobox "Preparing files..." 3 34
	# Get list of required variables
	vars=$(cat terraform.tfvars.default | cut -d'=' -f1)
	# Clean the slate
	rm terraform.tfvars
	# Set variables and write tfvars file with new values
	[ ${cpus} == 'auto' ] && { dialog --infobox "Autodetecting cpus..." 3 34; cpus=$(grep -e '^processor' /proc/cpuinfo|wc -l); }
	[ ${disk} == 'auto' ] && disk=""
	[ ${interface} == 'auto' ] && interface="$(route | grep '^default' | grep -o '[^ ]*$'| head -n1)"
	dialog --infobox "Writing terraform data..." 3 34
	for variable in ${vars}
	do
		declare ${variable}="$(echo ${!variable})"
		dialog --infobox "${variable}=\"${!variable}\"" 3 34
		echo "${variable}=\"${!variable}\"" >> terraform.tfvars
	done
}

# Function to run terraform plan
plan() { 
	dialog --infobox "Initializing..." 3 34
	terraform init >/dev/null

	dialog --infobox "Running plan..." 3 34
	# Clean slate
	rm ./.terraform/terraform.tfplan.txt
	terraform plan -no-color -out="./.terraform/terraform.tfplan" > ./.terraform/terraform.tfplan.txt &
	# Show progess of planning
	dialog --tailbox "./.terraform/terraform.tfplan.txt" 20 80
	results=$(cat "./.terraform/terraform.tfplan.txt")
	# Verify output with user
	output=$(
		dialog --stdout --title "Plan Results" \
		--yesno "Apply the following plan? \n\n ${results}" 20 80)
	case $? in
		0) apply; return;;
		1) output="main_menu"; return;;
	esac
}

# Function to apply terraform plan
apply() { 
	dialog --infobox "Initializing..." 3 34
	terraform init >/dev/null

	dialog --infobox "Applying..." 3 34
	# Clean slate
	rm "./.terraform/terraform.tfapply.txt"
	(terraform apply -auto-approve -no-color >> ./.terraform/terraform.tfapply.txt 2>&1;err=$?; echo -e "Exit code:\n${err}" >> ./.terraform/terraform.tfapply.txt) &
	dialog --tailbox "./.terraform/terraform.tfapply.txt" 20 80
	results=$(cat "./.terraform/terraform.tfapply.txt")
	# Read exit code from end of file
	err=$(tail -n1 ./.terraform/terraform.tfapply.txt)
	case $err in
		0) output=$(
			dialog --stdout --title "Results" \
				--yesno "Apply succeeded.\nProceed with deployment?" 7 20 )
			case $? in
				0) deploy; return;;
				1) output="main_menu"; return;;
			esac
		;;
		*) output=$(
			dialog --stdout --title "Results" \
				--yesno "\n Apply failed!\n Attempt destroy and retry? \n\n ${results}" 20 80)
			case $? in
				0) destroy; plan; return;;
				1) output="main_menu"; return;;
			esac
		;;
	esac
}

# Function to destroy resource with name specified
destroy() { 
	dialog --infobox "Initializing..." 3 34
	terraform init >/dev/null
	output=$(
		dialog --stdout --title "Confirm" \
			--yesno "\n Are you sure you want to destroy ${service}?" 9 20)
	case $? in
		0) dialog --title "Destrosying ${service}" --infobox "Removing terraform resources..." 3 44
			result=$(terraform destroy -auto-approve -no-color -input=false 2> /dev/null)
			dialog --title "Destroying ${service}" --infobox "Powering off VM..." 3 44
			result+=$(VBoxManage controlvm ${service} poweroff > /dev/null);
			dialog --title "Destroying ${service}" --infobox "Unregistering VM..." 3 44
			result+=$(VBoxManage unregistervm ${service} > /dev/null);
			cd ~/deploy/resources/env/virtualbox
			result+=$(rm -r ${service})
			dialog --title "Results" \
			--msgbox "${result}" 0 0;
			services;
			output="main_menu";
			return;;
		1) output="main_menu"; return;;
	esac
}

# Menu to select service to deploy
services() {
	cwd="$(pwd)"
	cd ~/deploy/resources/env/virtualbox
	SERVICE=$(
		dialog --stdout --title "Services" \
		--menu "Please choose a service:" 0 0 0 \
			$(i=0; oldIFS=${IFS}; IFS=$'\n'; for service in $(ls -1| grep -ve "menu.sh\|base" )
				do
					echo -n $service | cut -d'.' -f1 | rev | cut -d'/' -f1 | rev
					echo -n " service "
				done
				) \
			N "New service" \
		)
	err="${?}"
	cd "${cwd}"
	case "${err}" in
		0) [ "${SERVICE}" == 'N' ] && SERVICE=$(dialog --stdout --inputbox "Service:" 0 0)
			[ ! "${SERVICE}" ] && services;
			service=${SERVICE:-${service}}
			[ ! "${name}" ] && name="${service}";
			init "${service}";;
		1) [ "${service}" ] && output="main_menu";
			return ;;
		*) echo ERROR; exit 1 ;;
		esac
}

# Menu to select packages to deploy
packages() {
	cwd="$(pwd)"
	cd ~/deploy/resources/env/virtualbox
	PACKAGES=$(
		dialog --stdout --title "Services" \
		--checklist "Please choose packages to install:" 0 0 0 \
			$(i=0; oldIFS=${IFS}; IFS=$'\n'; for package in $(ls -1  "../../../packages/" )
				do
					echo -n $package | cut -d'.' -f1 | rev | cut -d'/' -f1 | rev
					echo " package " off
				done
				) \
			N "New package" off 
		)
	err="${?}"
	cd "${cwd}"
	case "${err}" in
		0) packages="${PACKAGES:-${packages}}";[ "${PACKAGES}" == 'N' ] && PACKAGES=$(dialog --stdout --inputbox "Package:" 0 0); init; output="main_menu"; return;;
		1) output="main_menu";return ;;
		*) echo ERROR; exit 1 ;;
		esac
}

# Function to deploy new resource and provision services
deploy() { 
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

	declare `terraform output | sed 's/ //'g` >/dev/null;
	if [ ! "${IPAddr}" ]; then errmsg 1 "Could not determine IP address. Did resources apply?"; output="main_menu"; return; fi
	ip="${IPAddr}"
	svc=${service}
	#deploy="vboxmanager"
	deploy="shayne"
	dialog --infobox "New Service: ${svc}" 0 0
	sleep 0.5
	#	cd ~/deploy/resources/env/virtualbox
#	[ -d "${svc}" ] || { cp -rv --preserve=links base "${svc}" && cd "${_}" || exit 1; } && cd "${svc}"

#	terraform providers
#	terraform init && terraform apply -auto-approve || exit 1
	dialog --infobox "Waiting for resource to accept default password..." 0 0
	while ! sshpass -p vagrant ssh-copy-id root@${ip} > /dev/null 2>&1 ; do
		sleep 0.3
	done
	dialog --infobox "Setting up ssh keys..." 0 0
	scp -r /home/${deploy}/.ssh/ root@${ip}:~/${deploy} 2>&1 | dialog --progressbox "Setting up ssh keys..." 15 80
	ssh root@${ip} sudo sh -c "whoami;
	useradd -m -G wheel ${deploy};
	mkdir -p /home/${deploy}/.ssh
	mv ~/${deploy}/* /home/${deploy}/.ssh/;
	echo \"${deploy}        ALL=(ALL)       NOPASSWD: ALL\" > /etc/sudoers.d/${deploy}
	chown ${deploy}. /home/${deploy} -R" 2>&1 | dialog --programbox "Setting up remote users..." 15 80
	ssh ${ip} "source /etc/os-release; cd; [ \${ID} == 'gentoo' ] && { sudo sed 's/localhost/gentoo/g' /etc/conf.d/hostname -i; } || { echo ${svc} > ~/hostname; sudo mv ~/hostname /etc; }; sudo reboot;"  2>&1 | dialog --progressbox "Setting hostname and rebooting..." 15 80
	dialog --infobox "Rebooting host..." 0 0
	sleep 5
	dialog --infobox "Waiting for host..." 0 0
	while ! ssh ${svc} whoami >/dev/null 2>&1; do
		sleep 0.3
	done
	dialog --infobox "Provisioning..." 0 0
	deployer provisioner $(cat ~/pw) ${svc} 2>&1 | dialog --programbox "Provisioning server..." 15 80
	dialog --infobox "Installing service..." 0 0
	for package in ${packages}; do
	  deployer ${package} $(cat ~/pw) ${ip} 2>&1 | dialog --programbox "Spinning up service. Installing ${package}..." 15 80
	done
	dialog --title "Deployment completed" --msgbox "The end." 0 0
	exit 0
}

# Save and exit dialog
save_exit() { dialog --title "Alert" \
	--yesno "\n Save settings as default?\n Warning: This will cause a full drift scan and auto-correct on current infrastructure!!" 9 50
	exit
}

# Temporary shim for getopts
[ ${1} != '--noX' ] && { [ ${DISPLAY} ] && dialog() { Xdialog "${@}"; } ;} || shift;
service="${1}"
action="${2}"

[ "${action}" ] && { init; deploy; }
# If the script is run while inside a terraformable resource, open it by default
[ -e ./terraform.tfvars.default ] && source ./terraform.tfvars.default
[ -e ./terraform.tfvars ] && source ./terraform.tfvars

# If no service is specified then ask for it, otherwise, run init
if [ ! ${service} ]; then services; else init "${@}"; fi

# Main Loop
while [ "${?}" != "1" ] && [ "${output}" != "" ] || [ "${output}" == "main_menu" ]
do
	main
done

dialog --infobox "Quitting..." 0 0
sleep 0.5