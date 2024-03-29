#!/bin/bash
#set -x;
password=${1}

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
if [[ "$(hostname | cut -d'.' -f1)" != "mysql" ]]; then echo "Can only be deployed to the mysql server. Aborting.."; exit; fi
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
USE="mysql perl php pdo" ${P_INSTALL} mysql phpmyadmin php-mysql httpd php-php-gettext mariadb-server

echo "Starting services..."
mkdir -p /var/lib/mysql
chown mysql.mysql /var/lib/mysql -R
mysql_install_db
for service in httpd mariadb
do
  systemctl enable $service
  systemctl restart $service
done
mysqladmin -u root password "${password}"
mysql -uroot -p"${password}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.37.%.%' IDENTIFIED BY '${password}' WITH GRANT OPTION;"

