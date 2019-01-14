#!/bin/bash
software="puppet"
services="puppet"

PACKAGE_init() { echo init;
	# if run from source, then accomodate
	[ ${0} != '-bash' ] && svc=$(basename "${0}"| cut -d. -f1)
	# declare svc before sourcing, if you so desire
	[ ! ${svc} ] && return
	
	# if service is undefined or script is default then get service name from input
	case $svc in
	  ''|'default') svc="${1}"; echo ${svc};;
	esac

	echo "Setting up ${svc}..."

	src=/etc/silverelitez/debug; [ -e ${src} ] && { set -x; debug=1; source ${src}; }
	src=/etc/silverelitez/config; [ -e ${src} ] && source ${src}
	source /etc/os-release

	echo -n Check for sudo/root...
	if [[ ${SUDO_USER} ]] || [[ ${USER} == 'root' ]]; then
	  echo Success;
	else
	  echo "Failed for ${USER}"
	  echo "Executing script as root..."
	  sudo ${0} ${@} || exit 1
	  exit
	fi
	if [[ ${TESTING_BRANCH} ]]; then 
	  branch="${TESTING_BRANCH}"
	  echo "Testing mode on branch ${branch}"
	else
	  branch="master"
	fi

	echo Hostname: $(hostname | cut -d'.' -f1)
	if [[ "$(hostname | cut -d'.' -f1)" != "${svc}" ]]; then echo "Can only be deployed to the ${svc} server. Aborting.."; return; fi
	[ ! $domain ] && { echo -n Discovering domain...;domain=$(sudo realm discover | head -n1);echo $domain; }
	[ ! $domain ] && { echo -n Reading resolv.conf for domain...;domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2); echo $domain; }
	[ ! $domain ] && { echo "Could not determine domain name. Fatal Error"; exit; }
	realm=$(echo ${domain} | cut -d. -f1)
	echo "Realm: ${realm}"
	tld=$(echo ${domain} | cut -d. -f2)
	echo "TLD: ${tld}"
	echo "Initializing functions..."
	giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/functions-${domain}.sh"
	[ $debug ] && echo Executing "${giturl}"
	source <( curl -s "${giturl}" | sed 's/^404:.*/echo 404 error - ${giturl}/g' | sed 's/^400:.*/echo 400 error - ${giturl}/g' | dos2unix; )

	echo "Loading translation layer..."
	translation_layer
}
PACKAGE_preinstall() { echo preinstall;
}
PACKAGE_install() { echo install;
	echo "Installing software..."
	#USE="apache2 ${svc}" ${P_INSTALL} httpd apache2 ${svc} nsre
	for package in ${software}; do
		USE="${svc}" P_INSTALL "${package}"
	done
}
PACKAGE_postinstall() { echo postinstall;
}
PACKAGE_configure() { echo configure;
	echo "Configuring ${svc}..."
	#is it backed up? no? back it up. yes? delete it
	# cd /etc/; [ ! -e /etc/${svc}.distro ] && mv ${svc} ${svc}.distro || rm -rf /etc/powerdns
	# cd /usr/src 
	# [ -e config ] && rm -rf config
	# git clone https://github.com/silverelitez-constitution/config.git
	# cd config
	# cp --preserve=links -r ${svc} /etc
	echo "Starting services..."
	for service in ${services}; do
		service ${service} restart || { echo "Error. Aborting"; return; }
	done
}
PACKAGE_tail() { echo tail; 
}

PACKAGE_init "${@}"
PACKAGE_preinstall
PACKAGE_install
PACKAGE_postinstall
PACKAGE_configure
PACKAGE_tail
