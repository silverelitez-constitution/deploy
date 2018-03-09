#!/bin/bash
# This deployment script has been lovingly crafted for
DEPLOY_ID="centos"

password=${1}

echo Hostname: $(hostname | cut -d'.' -f1)
if [[ "$(hostname | cut -d'.' -f1)" == "dc" ]]; then echo "Refusing to turn a domain controller into a client. Aborting..."; exit; fi

echo -n Check for sudo...
if [[ ! ${SUDO_USER} ]]; then
	echo "Failed"
	echo "Executing script as root..."
	sudo ${0} ${@} || exit 1
	exit
else
	echo Success
fi

echo "Setting time zone..."
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

echo "Install epel-release and dos2unix..."
yum install -y epel-release --quiet
yum update -y --quiet
yum install --quiet -y dos2unix

echo "Removing default command-not-found function..."
yum -y remove PackageKit-command-not-found --quiet

echo "Refresh yum cache..."
yum --quiet -y update
yum makecache --quiet

command_not_found_handle () {
    fullcommand="${@}";
    package=$(repoquery --whatprovides "*bin/${1}" -C --qf '%{NAME}' | head -n1);
    if [ ! $package ]; then
        echo "No package provides ${1}! Command doesn't exist...";
        return;
    fi;
    echo -n "The package ${package} is required to run '${fullcommand}'! Installing...";
    if sudo yum -t install --quiet -y "${package}"; then
		echo "Done!";
        echo "Okay, now let's try that again...shall we?";
        echo -e "$(show-prompt) ${fullcommand}";
        eval ${fullcommand};
    else
        echo "Err!";
		echo 'Unfortunately the installation failed :(';
    fi;
    retval=$?;
    return $retval
}

echo Update yum...
yum -t update -y

echo Install cache updater crontab...
echo -e "$(crontab -l)\n*/5 * * * * yum makecache --quiet" | sort -u | crontab

domain=$(realm discover | head -n1)
realm=$(echo ${domain} | cut -d"." -f1)
branch="master"
giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/global.sh"

echo Update global profile.d script...
curl -s ${giturl} | dos2unix > /etc/profile.d/global.sh
chown root.root /etc/profile.d/global.sh
chmod a+x /etc/profile.d/global.sh

user=${SUDO_USER}
realm=$(realm discover | head -n1)

if [[ ! ${user} ]]; then user="deployer"; fi #echo "Run as a sudo'er with a username that has domain auth!"; exit 1; fi
if [[ ! ${realm} ]]; then echo "The router/DHCP	server didn't return useful data!"; exit 1; fi

echo User is ${user}

domain=$(echo $realm | cut -d'.' -f1)

echo Installing required packages...
yum --quiet -t -y install $(realm discover ${realm} | grep 'required-package:' | cut -d':' -f2)
echo "${password}" | kinit "${user}@$(realm discover | grep 'realm-name:' | cut -d' ' -f4 | awk '{print toupper($0)}')"

echo Leaving currently joined realm...
realm leave
echo Discovering DHCP provided realm...
realm discover ${realm}
echo Joining ${realm}
realm join ${realm}

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
use_fully_qualified_names = True
fallback_homedir = /home/%u@%d
access_provider = ad
EOL

echo "Engaging sssd service..."
systemctl enable sssd
systemctl restart sssd
systemctl stop sssd
sed -i 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
systemctl restart sssd

echo Testing domain...
id ${user}@${realm} || exit 1