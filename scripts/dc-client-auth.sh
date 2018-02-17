# enable these lines for manual deployment. eg not using the deploy function as root
#if [ ! $1 ]; then echo 'Specify domain admin [user@realm.tld]'; exit 1; fi
#input=$1

#input='shayne@constitution.uss'
#user=$(echo $input | cut -d'@' -f1)
#realm=$(echo $input | cut -d'@' -f2)

which nmap >/dev/null || yum -y install nmap

user=${SUDO_USER}
#fucking network-steroids, yo
realm=$(which nmap>/dev/null || yum -y install nmap; nmap --script broadcast-dhcp-discover | grep 'Domain Name:' | cut -d':' -f2 | cut -d' ' -f2 2>/dev/null)

if [[ ! ${user} ]]; then echo "Run as a sudo'er with a username that has domain admin auth!"; exit 1; fi
if [[ ! ${realm} ]]; then echo "The router/DHCP	server didn't return useful data!"; exit 1; fi


domain=$(echo $realm | cut -d'.' -f1)

yum -y update
yum -y install realmd sssd oddjob oddjob-mkhomedir adcli samba-common

realm discover $realm

realm join --user $user $realm

id $domain\\$user

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

id $1
id $user
