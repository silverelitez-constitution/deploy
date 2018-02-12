#Install pre-requisites:
yum install -y lsb
yum install -y wget
yum install -y unzip
yum install -y nano
yum install -y java

#Download UniFi software:
cd /usr/src
wget -c https://dl.ubnt.com/unifi/5.6.29/UniFi.unix.zip || exit 1

#Create UniFi directories:
mkdir -p /opt/UniFi/data
mkdir -p /var/opt/UniFi/data
ln -s /var/opt/UniFi/data /opt/UniFi/data

#Extract UniFi software:
unzip UniFi.unix.zip -d /opt/

#Install MongoDB:
rpm --import https://www.mongodb.org/static/pgp/server-3.2.asc

cat >/etc/yum.repos.d/mongodb-org-3.2.repo << EOL
[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
EOL
yum install -y mongodb-org

#Create User and set permissions:
useradd -M unifi
usermod -L unifi
usermod -s /bin/false unifi
chown -R unifi:unifi /opt/UniFi
chown -R unifi:unifi /var/opt/UniFi

#Create unifi service:
cat >/var/opt/UniFi/unifi.service << EOL
[Unit]
Description=UniFi
After=syslog.target
After=network.target
[Service]
Type=simple
User=unifi
Group=unifi
ExecStart=/usr/bin/java -jar /opt/UniFi/lib/ace.jar start
ExecStop=/usr/bin/java -jar /opt/UniFi/lib/ace.jar stop
# Give a reasonable amount of time for the server to start up/shut down
TimeoutSec=300
[Install]
WantedBy=multi-user.target
EOL

ln -s /var/opt/UniFi/unifi.service /usr/lib/systemd/system/unifi.service

# Configure firewall rules:
#firewall-cmd --zone=public --add-port=8080/tcp --permanent
#firewall-cmd --zone=public --add-port=8443/tcp --permanent
#systemctl restart firewalld

#Enable and start service:
systemctl enable /var/opt/UniFi/unifi.service
systemctl start unifi.service
systemctl status unifi.service
