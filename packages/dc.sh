if [ ! $1 ]; then echo "Specify a domain name <domain.tld>"; exit 1; fi

yum remove -y gnome-boxes
yum autoremove -y
yum install epel-release -y
yum autoremove -y
yum update -y --skip-broken

yum install nano vim wget authconfig krb5-workstation -y

cd /etc/yum.repos.d/
wget http://wing-net.ddo.jp/wing/7/EL7.wing.repo -O EL7.wing.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/EL7.wing.repo

yum clean all
yum remove -y samba*
yum autoremove -y

yum update -y --skip-broken

#yum install -y samba samba-winbind-clients samba-winbind samba-client samba-dc samba-pidl samba-python samba-winbind-krb5-locator perl-Parse-Yapp perl-Test-Base python2-crypto samba-common-tools
yum install -y samba46 samba46-winbind-clients samba46-winbind samba46-client samba46-dc samba46-pidl samba46-python samba46-winbind-krb5-locator perl-Parse-Yapp perl-Test-Base python2-crypto samba46-common-tools

rm -rf /etc/krb5.conf
rm -rf /etc/samba/smb.conf

realm=${1:-}
domain=$(echo $realm | cut -d'.' -f1)

cat >/etc/systemd/system/samba.service << EOL
[Unit]
Description= Samba 4 Active Directory
After=syslog.target
After=network.target

[Service]
Type=forking
PIDFile=/var/run/samba.pid
ExecStart=/usr/sbin/samba

[Install]
WantedBy=multi-user.target
EOL

service libvirtd stop
systemctl disable libvirtd

systemctl enable samba


default_iface=$(awk '$2 == 00000000 { print $1 }' /proc/net/route)
ip=$(ip addr show dev "$default_iface" | awk '$1 ~ /^inet/ { sub("/.*", "", $2); print $2 }' | grep -v ':' | head -n1)
samba-tool domain provision --realm=$realm --domain=$domain --use-rfc2307 --host-ip=$ip
cp -v /var/lib/samba/private/krb5.conf /etc/krb5.conf.d/
systemctl restart samba
realm discover | grep 'required-package: ' | cut -d' ' -f4
