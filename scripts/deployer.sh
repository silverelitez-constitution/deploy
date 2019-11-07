#!/bin/bash

# replace with "cat $0basenamethingy | grep 'PACKAGES_' | cut -d'_' -f2" to auto scan for functions to run. probably use that for the custom packages
stages="init preinstall install postinstall configure tail"

gitsource() {
  script=${1:-default.sh}
  branch=${2:-master}
  [ ! $domain ] && domain=$(sudo grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
  realm=$(echo ${domain} | cut -d. -f1)
  gitsurl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/${script}"
  echo ${gitsurl}
  source <(curl -s ${gitsurl} | sed 's/^404:.*/echo 404 error - ${gitsurl}/g'  || echo echo Error)
}

#declare the pipeline stages
_init(){ :;}
_preinstall(){ :;}
_install(){ :;}
_postinstall(){ :;}
_configure(){ :;}
_tail(){ :;}

gitsource "packages/${1}"

PACKAGE_init() { echo Init...
	[ ! "${svc}" ] && svc=$(basename "$0"| cut -d. -f1)
  #svc=${${svc}:-$(basename "$0"| cut -d. -f1)}
	[ "${svc}" == 'default' ] && svc="${2}"
  #case ${svc} in; default) svc="${2}";; esac
	service="${svc}"
  
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
	#if [[ "$(hostname | cut -d'.' -f1)" != "${svc}" ]]; then echo "Can only be deployed to the ${svc} server. Aborting.."; return; fi
	[ ! $domain ] && { echo -n Discovering domain...;domain=$(sudo realm discover | head -n1);echo $domain; }
	[ ! $domain ] && { echo -n Reading resolv.conf for domain...;domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2); echo $domain; }
	[ ! $domain ] && { echo "Could not determine domain name. Fatal Error!"; exit; }
	realm=$(echo ${domain} | cut -d. -f1)
	echo "Realm: ${realm}"
	tld=$(echo ${domain} | cut -d. -f2)
	echo "TLD: ${tld}"
	echo "Initializing functions..."
	giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/functions-${domain}.sh"
	[ $debug ] && echo Executing "${giturl}"
	source <( curl -s "${giturl}" | sed 's/^404:.*/echo 404 error - ${giturl}/g' | sed 's/^400:.*/echo 400 error - ${giturl}/g' ; )

	echo "Loading translation layer..."
	translation_layer
  _init
    # run package-defined check to see if package is already installed and/or configured
  echo "Testing system for package evaluation..."
  [ "${test}" ] && ${test} && exit;
}
PACKAGE_preinstall() { echo Preinstall...
  _preinstall; 
}
PACKAGE_install() { _install;
	echo "Installing packages and software..."
	[ "${packages}" ] && P_INSTALL ${packages}
	[ "${software}" ] && P_INSTALL ${software}
}
PACKAGE_postinstall() { _postinstall;
}
PACKAGE_configure() { _configure;
	echo "Configuring ${svc}..."

	#is it backed up? no? back it up. yes? delete it
	# cd /etc/; [ ! -e /etc/${svc}.distro ] && mv ${svc} ${svc}.distro || rm -rf /etc/${svc}
	# cd /usr/src 
	# [ -e config ] && rm -rf config

	# git clone https://github.com/silverelitez-constitution/config.git
	# cd config
	# cp --preserve=links -r ${svc}/* /

	echo "Starting services..."
	# If no services were specified in package file then exit function, otherwise, (re)start services
  [ "${services}" ] || return 
  for service in ${services}
  do 
    # If service start succeeds, add it to the bootup 
    service ${service} restart && systemctl enable ${service}
  done
}
PACKAGE_tail() { _tail;
  [ "${test}" ] && ${test} && exit || exit 1;
}

# Run provisioning stages
for stage in ${stages}; do PACKAGE_${stage} "${@}"; done

echo "The End."
