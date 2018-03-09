#!/bin/bash
# This deployment script has been lovingly crafted for
#set -x;
source /etc/os-release

if [ ${ID} == 'ubuntu' ]; then
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:team-xbmc/ppa
sudo apt-get update
sudo apt-get install kodi -y
exit
fi

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "Defining locales..."
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 >/dev/null

echo Hostname: $(hostname | cut -d'.' -f1)
if [[ "$(hostname | cut -d'.' -f1)" != "media" ]]; then echo "Can only be deployed to the media server. Aborting.."; exit; fi

echo -n Check for sudo...
if [[ ! ${SUDO_USER} ]]; then
	echo "Failed"
	echo "Executing script as root..."
	sudo ${0} ${@} || exit 1
	exit
else
	echo Success
fi

echo "Prepare git..."
which git || yum install -y git --quiet
cd /usr/src
if [ -e /usr/src/xbmc ]; then 
  cd xbmc && git pull && cd /usr/src
else
  git clone git://github.com/xbmc/xbmc.git
fi

XBMC=/usr/src/xbmc
I="yum install -y --skip-broken --quiet "
E="yum erase -y --skip-broken "
RI="rpm -i --replacefiles --nodeps "
RE="rpm -e --nodeps "

echo "Install needed packages..."
rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
rpm -Uvh http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
yum-config-manager --enable rhel-server-rhscl-7-rpms

yum clean all
rm -rf /var/cache/yum
yum update -y
yum makecache
#yum autoremove -y

rm -f /bin/gcc53 /bin/c++ /bin/c /bin/cc /bin/gcc /bin/gcc-cpp

url="https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/"
${RE} "${url}libtool-base-2.4.2-13.mga5.x86_64.rpm"
${RE} libtool-base-2.4.2-13.mga5.x86_64
${RE} "${url}libtool-2.4.2-13.mga5.x86_64.rpm"
${RE} libtool-2.4.2-13.mga5.x86_64
${I} libtool
${RE} "${url}binutils-2.24-12.mga5.x86_64.rpm"
${RE} binutils-2.24-12.mga5.x86_64
${I} binutils 
${RE} "${url}gcc-4.9.2-4.mga5.x86_64.rpm"
${RE} gcc-4.9.2-4.mga5.x86_64
${I} gcc 
${RE} "${url}gcc-cpp-4.9.2-4.mga5.x86_64.rpm"
${RE} gcc-cpp-4.9.2-4.mga5.x86_64
${I} gcc-cpp 
${RE} "${url}glibc-2.20-27.mga5.x86_64.rpm"
${RE} glibc-2.20-27.mga5.x86_64
${I} glibc 
${RE} "${url}libstdc++6-4.9.2-4.mga5.x86_64.rpm"
${RE} libstdc++6-4.9.2-4.mga5.x86_64
${I} libstdc++
${RE} "${url}libstdc++-devel-4.9.2-4.mga5.x86_64.rpm"
${RE} libstdc++-devel-4.9.2-4.mga5.x86_64
${I} libstdc++-devel
${RE} "${url}gcc-c++-4.9.2-4.mga5.i586.rpm"
${RE} gcc-c++-4.9.2-4.mga5.i586 
${I} gcc-c++ 

${I} libtool binutils gcc gcc-cpp glibc libstdc++ libstdc++-devel gcc-c++ 


exit

${I} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/dash-static-0.5.7-6.mga5.x86_64.rpm
${I} https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/l/libmpc-1.1.0-1.fc29.x86_64.rpm
${I} https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/l/libmpc-devel-1.1.0-1.fc29.x86_64.rpm
${I} cmake cpp gpp c++ g++ libtool gcc-c++ ghc-OpenGL-devel librx-devel php-JsonSchema python34-jsonschema gettext-devel nasm yasm-devel ffms2-devel libXrandr-devel python-devel libxml2-devel libass-devel openssl-devel swig mesa-libEGL-devel gegl-devel expat-devel fam-devel iniparser-devel lzo-devel popt-devel readline-devel libacl-devel libaio-devel libattr-devel expat-devel libjpeg-devel lzo-devel libwbclient-devel gamin-devel iniparser-devel popt-devel readline-devel tinyxml-devel libsqlite3x-devel taglib-devel fmt-devel freetype-devel fribidi-devel rapidjson-devel libcurl-devel expat-devel libuuid-devel libpng-devel giflib-devel openjpeg-devel libcdio-devel libjpeg-turbo-devel zlib-devel lzo-devel curl autoconf automake afpfs-ng-devel libvdpau-devel libva-devel libbluray-devel libdca-devel librtmp-devel lame-devel


echo "Install libnfs..."
wget -nc https://github.com/downloads/sahlberg/libnfs/libnfs-1.3.0.tar.gz
tar -xzf libnfs-1.3.0.tar.gz
cd libnfs-1.3.0
./bootstrap
./configure
make
make install
su -c 'echo /usr/local/lib > /etc/ld.so.conf.d/local-libs.conf'
ldconfig
cd ..

echo "Patch afpfs-ng and libmysqlclient.so..."
sed --in-place=.BAK 's#<\(afp_protocol\|libafpclient\).h>#<afpfs-ng/\1.h>#' /usr/include/afpfs-ng/afp.h
ln -s /usr/lib/mysql/libmysqlclient.so.??.0.0 /usr/lib/libmysqlclient.so

echo "Install cmake..."
yum -y remove cmake
wget -nc https://cmake.org/files/v3.11/cmake-3.11.0-rc2-Linux-x86_64.tar.gz 
tar -zxf cmake-3.11.0-rc2-Linux-x86_64.tar.gz
cd cmake-3.11.0-rc2-Linux-x86_64/
cp -r * /usr/
cd ..

echo "Compile kodi..."

cd ${XBMC}
mkdir -p /var/lib/rpm/alternatives
# yum remove cpp gpp c++ g++ libtool gcc-c++ -y
# ${RI}  "https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/libtool-base-2.4.2-13.mga5.x86_64.rpm"
# ${RI}  "https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/libtool-2.4.2-13.mga5.x86_64.rpm"
# ${RI} https://rpmfind.net/linux/mageia/distrib/cauldron/x86_64/media/core/release/info-install-6.1-1.mga6.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/binutils-2.24-12.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/gcc-4.9.2-4.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/gcc-cpp-4.9.2-4.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/updates/glibc-2.20-27.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/libstdc++6-4.9.2-4.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/libstdc++-devel-4.9.2-4.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/gcc-c++-4.9.2-4.mga5.i586.rpm
# ln -sf /bin/c++ /bin/c
# ln -sf /bin/c++ /bin/cc
# ln -sf /bin/c++ /bin/gcc

#wget "https://github.com/silverelitez-constitution/deploy/blob/master/packages/gcc53-c++-5.3.0-1.el6.x86_64.rpm?raw=true"
#mv gcc53-c++-5.3.0-1.el6.x86_64.rpm\?raw\=true gcc53-c++-5.3.0-1.el6.x86_64.rpm
#${I} gcc53-c++-5.3.0-1.el6.x86_64.rpm && rm gcc53-c++-5.3.0-1.el6.x86_64.rpm
# ln -sf /bin/gcc53 /bin/c++
# ln -sf /bin/gcc53 /bin/c
# ln -sf /bin/gcc53 /bin/cc
# ln -sf /bin/gcc53 /bin/gcc

mkdir -p ${XBMC}/kodi-build; cd $_
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build . -- VERBOSE=1 -j$(grep '^processor' /proc/cpuinfo | cut -d':' -f2 | tail -n1)
