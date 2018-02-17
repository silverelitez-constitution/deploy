yum groupinstall "server with gui"

rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm

cat >/etc/yum.repos.d/xrdp.repo << EOL
[xrdp]
name=xrdp
baseurl=http://li.nux.ro/download/nux/dextop/el7/x86_64/
enabled=1
gpgcheck=0
EOL

yum -y update

yum -y install xrdp tigervnc-server

systemctl start xrdp.service
netstat -antup | grep xrdp && systemctl enable xrdp.service
