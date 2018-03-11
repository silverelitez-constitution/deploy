alias i='sudo yum -y install '
P_INSTALL="apt install -y "
P_REMOVE="apt remove -t "
P_INSTALL_PIP() { sudo apt --quiet -y install gcc python34-pip python34-devel python34-setuptools; }
P_UPDATE() { sudo apt update -y; }
P_NAME() { echo "$(sudo dpkg -S games/${1};sudo dpkg -S bin/${1})" | cut -d':' -f1; } 
P_BINARY() { apt-file list sl | grep -e "/games/${1}\|/bin/${1}"; }
P_UPDATES() { echo -n; }
PG_BASH_COMPLETION() { ${P_INSTALL} --quiet *bash-complet*; }

P_INSTALL+=" --quiet "
P_REMOVE+=" --quiet "

_SHELL_TRANSLATOR=1