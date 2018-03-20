#!/bin/bash
# This deployment script has NOT been ravenously tested on:
# Centos 7, Ubuntu 17.10, Gentoo 17.1
source /etc/os-release

# Resources
gitsource() {
  script=${1:-default.sh}
  gitsurl="https://raw.githubusercontent.com/silverelitez-${domain}/deploy/master/${script}"
  source <(curl -s ${gitsurl} | sed 's/^404:.*/echo 404 error - ${gitsurl}/g' | sed 's/^400:.*/echo 400 error - ${gitsurl}/g' | dos2unix || echo echo Error)
}
is_sudo() {
  echo -n Check for sudo...
  if [[ ! ${SUDO_USER} ]]; then
    echo "Failed! Executing script as root..."
	[ ${debug} ] && echo ${0} ${@}
    sudo ${0} ${@} || exit 1
    exit
  else
    user=${SUDO_USER}
    echo "Success as ${user}"
  fi
}
q_install() {
  binary=${1}
  package=${2:-${binary}}
  which ${binary}  >/dev/null || { echo "Install ${package}..."
    case "${ID}" in
      centos) P_INSTALL="yum install -y " ;;
      ubuntu) P_INSTALL="apt install -y " ;;
      gentoo) P_INSTALL="emerge ";;
	  *) echo "No distro declared. Please manually install ${package} for ${binary}"
    esac; 
	P_INSTALL+="--quiet "
    ${P_INSTALL} ${package}
  }
}

# Steps
prepare_host() {
  echo "Preparing host..."
cat >/etc/sysctl.d/00-noipv6.conf <<EOL
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOL
  sysctl -p  
  password=${1}
  q_install dos2unix
  q_install applydeltarpm deltarpm
  ${P_INSTALL} nspr yum-utils
  [ ${ID} == 'gentoo' ] && { echo -e 'y\n' | layman -a sabayon; emerge realmd --quiet; } || { q_install realm realmd; q_install kinit krb5-workstation; }
  echo Hostname: $(hostname | cut -d'.' -f1)
  if [[ "$(hostname | cut -d'.' -f1)" == "dc" ]]; then echo "Refusing to turn a domain controller into a client. Aborting..."; exit; fi
  [ ! ${realm} ] && { echo -n Discovering realm...;realm=$(sudo realm discover | head -n1);echo $realm; }
  [ ! ${realm} ] && { echo -n Reading resolv.conf for realm...;realm=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2); echo $realm; }
  [ ! ${realm} ] && { echo No realm could be discovered. Aborting...; exit; }
  if [[ ${password} ]]; then 
    echo "${password}" | kinit "${user}@$(echo ${realm} | awk '{print toupper($0)}')"
  else
	echo "Password not supplied!"
	kinit "${user}@$(echo ${realm} | awk '{print toupper($0)}')"
  fi
  echo "Setting time zone..."
  ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  domain=$(echo $realm | cut -d'.' -f1)
  if [[ ! ${user} ]]; then user="deployer"; fi #echo "Run as a sudo'er with a username that has domain auth!"; exit 1; fi
  if [[ ! ${realm} ]]; then echo "The router/DHCP  server didn't return useful data!"; exit 1; fi
  echo "Loading Translator..."
  gitsource resources/translators/default.sh
}
install_packages() {
  echo "Update packager..."
  [[ ${ID} == 'centos' ]] && { echo "Install delta-rpm etc..."; ${P_INSTALL} yum-utils krb5-workstation deltarpm; }
  [[ ${ID} == 'centos' ]] && { echo "Remove PackageKit-command-not-found..."; ${P_REMOVE} -y PackageKit-command-not-found; }
  P_UPDATE
  [[ ${ID} == 'centos' ]] && { yum-complete-transaction --cleanup-only; yum makecache --quiet; }

  echo "Installing required packages..."
  for package in $(sudo realm discover ${realm} | grep 'required-package:' | cut -d':' -f2)
  do 
    ${P_INSTALL} ${package}
 done
}
join_domain() {
  echo Leaving currently joined realm...
  realm leave
  echo Discovering DHCP provided realm...
  realm discover ${realm}
  echo Joining ${realm}
  realm join ${realm}
}
update_global_script() {
  echo Update global profile.d script...
  giturl="https://raw.githubusercontent.com/silverelitez-${domain}/deploy/master/scripts/profile.d/global.sh"
  curl -s ${giturl} | dos2unix > /etc/profile.d/global.sh
  chown root.root /etc/profile.d/global.sh
  chmod a+x /etc/profile.d/global.sh
}
install_services() {
  echo "Installing services..."
  [[ ${ID} == "centos" ]] && { echo "Installing crontab..."; echo -e "$(crontab -l)\n*/5 * * * * yum makecache --quiet" | sort -u | crontab; }
  echo "Writing sssd.conf..."
  cat >/etc/sssd/sssd.conf << EOL
[sssd]
domains = $realm
config_file_version = 2
services = nss, pam

[domain/$realm]
ad_domain = $realm
krb5_realm = $realm
realmd_tags = manages-system joined-with-samba
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = False
fallback_homedir = /home/%u@%d
access_provider = ad
EOL
  echo "Engaging sssd service..."
  case "${ID}" in
    gentoo) rc-update add sssd default; /etc/init.d/sssd restart;;
    centos|ubuntu) systemctl enable sssd; systemctl restart sssd;;
  esac
}
test_install() {
  echo "Testing domain..."
  id ${user}@${realm} && echo "Domain joined!" || exit 1
  mkdir -p /etc/silverelitez
}
the_end() {
  echo "The End.";
}

is_sudo ${@}

prepare_host "${@}"
install_packages
join_domain
update_global_script
install_services
test_install
the_end