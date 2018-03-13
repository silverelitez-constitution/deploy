#!/bin/bash

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
ln -sf ${hostnamedir} ${ipdir}/public-html

echo "Installing NayruPanel..."
cd ${hostnamedir}
git clone https://github.com/thesokrin/NayruPanel.git

echo "The End."
