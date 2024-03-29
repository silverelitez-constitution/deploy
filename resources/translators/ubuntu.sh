unset UCF_FORCE_CONFFOLD
export UCF_FORCE_CONFFNEW=YES

export DEBIAN_FRONTEND=noninteractive

alias i='sudo yum -y install '
P_INSTALL="sudo apt -o Apt::Color=0 install -y "
P_REMOVE="sudo apt -o Apt::Color=0 remove -t "
P_INSTALL_PIP() { sudo apt -o Apt::Color=0 --force-confnew,confdef --quiet -y install gcc python-pip; }
P_UPDATE() { sudo apt -o Apt::Color=0 update -y --force-yes; }
P_UPGRADE() { sudo ucf --purge /boot/grub/menu.lst; sudo apt -o Apt::Color=0 -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" upgrade -fuy --force-yes; }
P_NAME() { release="$(lsb_release -c | cut -f2)"; curl -s "https://packages.ubuntu.com/search?searchon=contents&keywords=${1}&mode=exactfilename&suite=${release}&arch=any" | grep "<a href=\"/${release}/" | cut -f3 -d'/' | cut -d'"' -f1 | head -n1; }
P_SEARCH() { apt -o Apt::Color=0 search "${@}"; }
P_BINARY() { apt-file list ${1} | grep -e "/games/${1}\|/bin/${1}"; }
P_UPDATES() { echo -n; }
PG_BASH_COMPLETION() { ${P_INSTALL} --quiet *bash-complet*; }
P_INSTALL+=" --quiet "
P_REMOVE+=" --quiet "

_SHELL_TRANSLATOR=1