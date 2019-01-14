alias i='sudo yum -y install '
P_INSTALL="apt -o Apt::Color=0 install -y "
P_REMOVE="apt -o Apt::Color=0 remove -t "
P_INSTALL_PIP() { sudo apt -o Apt::Color=0 --quiet -y install gcc python-pip; }
P_UPDATE() { sudo apt -o Apt::Color=0 update -y; }
P_UPGRADE() { sudo apt -o Apt::Color=0 upgrade -y; }
P_NAME() { echo "$(sudo apt-file search -x games/${1}$;sudo apt-file search -x bin/${1}$ )" | cut -d':' -f1; } 
P_SEARCH() { apt -o Apt::Color=0 search "${@}"; }
P_BINARY() { apt-file list ${1} | grep -e "/games/${1}\|/bin/${1}"; }
P_UPDATES() { echo -n; }
PG_BASH_COMPLETION() { ${P_INSTALL} --quiet *bash-complet*; }
P_INSTALL+=" --quiet "
P_REMOVE+=" --quiet "

_SHELL_TRANSLATOR=1