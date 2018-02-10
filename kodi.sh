yum install -y epel-release
yum update -y

yum install -y git
cd /usr/src
git clone git://github.com/xbmc/xbmc.git
XBMC=xbmc

sudo rpm -Uvh https://www.rpmfind.net/linux/dag/redhat/el5/en/x86_64/dag/RPMS/rpmforge-release-0.3.6-1.el5.rf.x86_64.rpm
sudo yum -y install libvdpau-devel libva-devel libbluray-devel

sudo yum -y install libdca-devel   # for DTS support
sudo yum -y install librtmp-devel  # for rtmp streaming support
sudo yum -y install lame-devel     # for mp3 encoding support using lame

#make -C tools/depends/native/JsonSchemaBuilder/
#sudo cp tools/depends/native/JsonSchemaBuilder/bin/JsonSchemaBuilder /usr/local/bin
#sudo chmod 775 /usr/local/bin/JsonSchemaBuilder

#sudo sed --in-place=.BAK 's#<\(afp_protocol\|libafpclient\).h>#<afpfs-ng/\1.h>#' /usr/include/afpfs-ng/afp.h

#sudo ln -s /usr/lib/mysql/libmysqlclient.so.??.0.0 /usr/lib/libmysqlclient.so

#cd ${XBMC} # XBMC=xbmc when you used git and XBMC=xbmc-master when you downloaded the ZIP file
#./bootstrap

wget https://github.com/downloads/sahlberg/libnfs/libnfs-1.3.0.tar.gz
tar -xzf libnfs-1.3.0.tar.gz
cd libnfs-1.3.0
./bootstrap
./configure
make
sudo make install
su -c 'echo /usr/local/lib > /etc/ld.so.conf.d/local-libs.conf'
sudo ldconfig
cd ..






sudo sed --in-place=.BAK 's#<\(afp_protocol\|libafpclient\).h>#<afpfs-ng/\1.h>#' /usr/include/afpfs-ng/afp.h
#Just to appease the configure application, you may have to show it where libmysqlclient is.

sudo ln -s /usr/lib/mysql/libmysqlclient.so.??.0.0 /usr/lib/libmysqlclient.so
#Now we are ready for to build Kodi. First, run the bootstrap command:

cd ${XBMC} # XBMC=xbmc when you used git and XBMC=xbmc-master when you downloaded the ZIP file
./bootstrap
#Are you going to use LIRC and a remote control? Starting with Fedora 12 the default LIRC socket file name has changed to /var/run/lirc/lircd (from /dev/lircd). You might need to provide the configure script with this parameter before compiling XBMC:

#./configure --with-lirc-device=/var/run/lirc/lircd
#If not, simply do

#./configure
#Or if you want to have XBMC/Kodi installed in an alternative directory (e.g. /opt/kodi) use

./configure --prefix=/opt/kodi
#There are a lot more options available for the configure script. To see all of them use

#./configure --help
#With the above installed packages this should go smoothly :)

#7 Build
make