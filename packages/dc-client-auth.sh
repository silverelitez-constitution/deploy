#!/bin/bash
# This deployment script has been lovingly crafted for
DEPLOY_ID="centos"

command_not_found_handle () {
    fullcommand="${@}";
    package=$(repoquery --whatprovides "*bin/${1}" -C --qf '%{NAME}' | head -n1);
    if [ ! $package ]; then
        echo "No package provides ${1}! Command doesn't exist...";
        return;
    fi;
    echo -n "The package ${package} is required to run '${fullcommand}'! Installing...";
    if sudo yum install --quiet -y "${package}"; then
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

if [[ ! ${SUDO_USER} ]]; then
	sudo ${0} || exit 1
	exit 
fi

yum update -y
echo -e "$(crontab -l)\n*/5 * * * * yum makecache --quiet" | sort -u | crontab

domain=$(realm list | head -n1)
realm=$(echo ${domain} | cut -d"." -f1)
branch="master"
giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/global.sh"

curl -s ${giturl} | dos2unix > /etc/profile.d/global.sh
chown root.root /etc/profile.d/global.sh
chmod a+x /etc/profile.d/global.sh

source /etc/bashrc

echo Hostname: $(hostname | cut -d'.' -f1)
if [[ "$(hostname | cut -d'.' -f1)" == "dc" ]]; then echo "Refusing to turn a domain controller into a client. Aborting..."; exit; fi

# enable these lines for manual deployment. eg not using the deploy function as root
#if [ ! $1 ]; then echo 'Specify domain admin [user@realm.tld]'; exit 1; fi
#input=$1

#input='shayne@constitution.uss'
#user=$(echo $input | cut -d'@' -f1)
#realm=$(echo $input | cut -d'@' -f2)

#which nmap >/dev/null || yum -y install nmap

user=${SUDO_USER}

# scripting-on-steroids, yo. the beginnings of the automated distro meld
realm=$(which nmap>/dev/null || yum -y install nmap; nmap --script broadcast-dhcp-discover | grep 'Domain Name:' | cut -d':' -f2 | cut -d' ' -f2 2>/dev/null)

if [[ ! ${user} ]]; then user="deployer"; fi #echo "Run as a sudo'er with a username that has domain auth!"; exit 1; fi
if [[ ! ${realm} ]]; then echo "The router/DHCP	server didn't return useful data!"; exit 1; fi


domain=$(echo $realm | cut -d'.' -f1)

yum -y install sssd oddjob oddjob-mkhomedir adcli samba-common

realm leave; sleep 2
realm discover ${realm}
realm join --unattended --no-password ${realm} | grep 'required-package: ' #--user $user $realm

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

systemctl enable sssd
systemctl restart sssd
systemctl stop sssd
sed -i 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
systemctl restart sssd

id ${user}@${realm} || exit 1