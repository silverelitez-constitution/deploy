#!/bin/bash
# This deployment script has NOT been ravenously tested on:
# Centos 7, Ubuntu 17.10, Gentoo 17.1

# Resources
gitsource() {
  gitsurl="https://raw.githubusercontent.com/silverelitez-${domain}/deploy/master/${script}"
  source <(curl -s ${gitsurl} | sed 's/^404:.*/echo 404 error/g' | dos2unix || echo echo Error)
}
is_sudo() {
  echo -n Check for sudo...
  if [[ ! ${SUDO_USER} ]]; then
    echo "Failed! Executing script as root..."
    sudo ${0} ${@} || exit 1
    exit
  else
    user=${SUDO_USER}
    echo "Success as ${user}"
  fi
}

# Steps
prepare_host() {
  echo "Preparing host..."
  is_sudo
  echo Hostname: $(hostname | cut -d'.' -f1)
  if [[ "$(hostname | cut -d'.' -f1)" == "dc" ]]; then echo "Refusing to turn a domain controller into a client. Aborting..."; exit; fi
  echo "Setting time zone..."
  ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  realm=$(realm discover | head -n1)
  domain=$(echo $realm | cut -d'.' -f1)
  password=${1}
  if [[ ! ${user} ]]; then user="deployer"; fi #echo "Run as a sudo'er with a username that has domain auth!"; exit 1; fi
  if [[ ! ${realm} ]]; then echo "The router/DHCP  server didn't return useful data!"; exit 1; fi
  if [[ ! ${password} ]]; then echo "Password not supplied!"; exit 1; fi
  which dos2unix || { echo "Install dos2unix..."
    case "${ID}" in
      centos) P_INSTALL="yum install -y " ;;
      ubuntu) P_INSTALL="apt install -y " ;;
      gentoo) P_INSTALL="emerge ";;
    esac; 
	P_INSTALL+="--quiet "
    ${P_INSTALL} dos2unix
  }
  gitsource resources/translators/default.sh
  echo "${password}" | kinit "${user}@$(realm discover | grep 'realm-name:' | cut -d' ' -f4 | awk '{print toupper($0)}')"
}
install_packages() {
  echo "Installing required packages..."
  [[ ${ID} == 'centos' ]] && { echo "Install epel-release..."; ${P_INSTALL} epel-release; }
  P_UPDATE
  [[ ${ID} == 'centos' ]] && ${P_REMOVE} PackageKit-command-not-found --quiet

  echo "Update packager..."
  P_UPDATE
  [[ ${ID} == 'centos' ]] && yum makecache --quiet
  ${P_INSTALL} $(realm discover ${realm} | grep 'required-package:' | cut -d':' -f2)
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
  systemctl enable sssd
  systemctl restart sssd
}
test_install() {
  echo "Testing domain..."
  id ${user}@${realm} && echo "Domain joined!" || exit 1
}
the_end() {
  echo "The End.";
}

prepare_host "${@}"
install_packages
join_domain
update_global_script
install_services
test_install
the_end