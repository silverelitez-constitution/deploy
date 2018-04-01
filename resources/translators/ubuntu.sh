alias i='sudo yum -y install '
P_INSTALL="apt install -y "
P_REMOVE="apt remove -t "
P_INSTALL_PIP() { sudo apt --quiet -y install gcc python-pip; }
P_UPDATE() { sudo apt update -y; }
P_UPGRADE() { sudo apt upgrade -y; }
P_NAME() { echo "$(sudo apt-file search -x games/${1}$;sudo apt-file search -x bin/${1}$ )" | cut -d':' -f1; } 
P_SEARCH() { apt search "${@}"; }
P_BINARY() { apt-file list ${1} | grep -e "/games/${1}\|/bin/${1}"; }
P_UPDATES() { echo -n; }
PG_BASH_COMPLETION() { ${P_INSTALL} --quiet *bash-complet*; }
P_INSTALL+=" --quiet "
P_REMOVE+=" --quiet "

_SHELL_TRANSLATOR=1