#!/bin/bash
#set -x;
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
if [[ "$(hostname | cut -d'.' -f1)" != "dns" ]]; then echo "Can only be deployed to the dns server. Aborting.."; exit; fi
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
source <( curl -s "${giturl}" | sed 's/^404:.*/echo 404 error - ${giturl}/g' | sed 's/^400:.*/echo 400 error - ${giturl}/g' | dos2unix; )
echo "Loading translation layer..."
translation_layer

echo "Installing packages..."
USE="mysql perl php pdo" ${P_INSTALL} php-pdo php-mysql php-mcrypt httpd mod_perl php

echo "Configuring apache..."
# is httpd backed up? no? back it up. yes? delete /etc/httpd
cd /etc/; [ ! -e /etc/httpd.distro ] && mv httpd httpd.distro || rm -rf /etc/httpd
cd /usr/src 
[ -e config ] && rm -rf config

git clone https://github.com/silverelitez-constitution/config.git
cd config
cp --preserve=links -r httpd /etc

for i in $(seq 1 5);do killall -9 httpd 2>/dev/null; done
service httpd restart || { echo "Error. Aborting!"; exit 1; }

echo "Configuring webspace..."
ipdir="/var/www/$( host $(hostname) | sed 's/[^0-9.]//g' | awk -F'.' '{print $4,$3,$2}' | sed 's/ /\//g')"
hostnamedir="/var/www/${tld}/${realm}/$(hostname)"
echo "IP based directory: ${ipdir}"
echo "Hostname based directory: ${hostnamedir}"

cd /var/www
mkdir -p ${ipdir}
mkdir -p ${hostnamedir}
cd $_ && ln -sf NayruPanel public-html
rm public-html
ln -sf ${hostnamedir}/NayruPanel ${ipdir}/public-html

echo "Installing NayruPanel..."
cd ${hostnamedir}
git clone https://github.com/thesokrin/NayruPanel.git

echo "The End."
