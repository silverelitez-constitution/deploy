#!/bin/bash
# This deployment script has been lovingly crafted for
DEPLOY_ID="centos"

#set -x;

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
I="yum install -y --skip-broken "
RI="rpm -i --replacefiles --nodeps "

echo "Install needed packages..."
rpm --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
rpm -Uvh https://www.rpmfind.net/linux/dag/redhat/el5/en/x86_64/dag/RPMS/rpmforge-release-0.3.6-1.el5.rf.x86_64.rpm

yum remove libmpc cpp gcc gcc-cpp cmake gcc-c++ -y
yum-config-manager --enable rhel-server-rhscl-7-rpms
#Install gcc, g++ version 4.9.2 : # 
${I} devtoolset-3-gcc-c++
${I} librx-devel php-JsonSchema python34-jsonschema mingw64-gettext gettext-devel nasm yasm-devel ffms2-devel libXrandr-devel python-devel libxml2-devel libass-devel openssl-devel swig mesa-libEGL-devel gegl-devel expat-devel fam-devel gif-devel inet-devel iniparser-devel jfsdm-devel jpeg-devel lib-devel ltdl-devel lzo-devel md-devel popt-devel pthread-devel pthreads-devel readline-devel resolv-devel rt-devel sendfile-devel termlib-devel unwindptrace-devel wbclient-devel xdsm-devel z-devel  libacl-devel libaio-devel libattr-devel libavahiclient-devel libavahicommon-devel libc-devel libcpluff-devel libcr-devel libcrypto-devel libdl-devel libdm-devel libdmapi-devel libexc-devel expat-devel libgif-devel libinet-devel libjfsdm-devel libjpeg-devel liblib-devel libltdl-devel lzo-devel libmd-devel libpthread-devel libpthreads-devel libresolv-devel librt-devel libsendfile-devel libtermlib-devel libunwindptrace-devel libwbclient-devel libxdsm-devel libz-devel gamin-devel iniparser-devel popt-devel readline-devel tinyxml-devel libsqlite3x-devel taglib-devel fmt-devel freetype-devel fribidi-devel pcre2-devel pcre-devel rapidjson-devel libcurl-devel expat-devel libuuid-devel libpng-devel giflib-devel openjpeg-devel libcdio-devel libjpeg-turbo-devel zlib-devel lzo-devel autotools-devel curl autoconf automake afpfs-ng-devel libtool libvdpau-devel libva-devel libbluray-devel libdca-devel librtmp-devel lame-devel

# mkdir -p /var/lib/rpm/alternatives
# ${I} https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/l/libmpc-1.1.0-1.fc29.x86_64.rpm
# ${I} https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/l/libmpc-devel-1.1.0-1.fc29.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/cauldron/x86_64/media/core/release/info-install-6.1-1.mga6.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/cauldron/x86_64/media/core/release/binutils-2.29.1-8.mga7.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/gcc-4.9.2-4.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/gcc-cpp-4.9.2-4.mga5.x86_64.rpm
# ${I} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/dash-static-0.5.7-6.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/updates/glibc-2.20-27.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/libstdc++6-4.9.2-4.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/x86_64/media/core/release/libstdc++-devel-4.9.2-4.mga5.x86_64.rpm
# ${RI} https://rpmfind.net/linux/mageia/distrib/5/i586/media/core/release/gcc-c++-4.9.2-4.mga5.i586.rpm

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
wget -nc https://cmake.org/files/v3.11/cmake-3.11.0-rc2-Linux-x86_64.tar.gz 
tar -zxf cmake-3.11.0-rc2-Linux-x86_64.tar.gz
cd cmake-3.11.0-rc2-Linux-x86_64/
cp -r * /usr/
cd ..

echo "Compile kodi..."
cd ${XBMC} # XBMC=xbmc when you used git and XBMC=xbmc-master when you downloaded the ZIP file

mkdir kodi-build; cd kodi-build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local

#yum install https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/l/libstdc++-8.0.1-0.16.fc29.x86_64.rpm
#yum install https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/l/libstdc++-devel-8.0.1-0.16.fc29.x86_64.rpm
#yum install https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/g/gcc-8.0.1-0.16.fc29.x86_64.rpm
#yum install https://rpmfind.net/linux/fedora/linux/development/rawhide/Everything/x86_64/os/Packages/g/gcc-c++-8.0.1-0.16.fc29.x86_64.rpm

cmake --build . -- VERBOSE=1 -j1 #$(grep '^processor' /proc/cpuinfo | cut -d':' -f2 | tail -n1)
