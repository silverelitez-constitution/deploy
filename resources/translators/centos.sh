alias i='sudo yum -y install '
P_INSTALL="sudo yum install -y "
P_NAME() { repoquery --cache -q -C --qf %{NAME} --whatprovides *bin/${1}; }
P_REMOVE="sudo yum remove -y "
P_BINARY() { repoquery -l ${1} | grep bin | rev | cut -d'/' -f1 | rev; }
P_INSTALL_PIP() { sudo yum --quiet -y install gcc python34-pip python34-devel python34-setuptools; }
P_UPDATES() { yum list updates | grep epel | grep -v '* epel:' | cut -d' ' -f1; }
P_UPDATE() { sudo yum update -y; }
P_UPGRADE() { sudo yum upgrade -y; }
P_SEARCH() { yum search "${@}"; }
PG_BASH_COMPLETION() {
  ${P_INSTALL} --cacheonly *bash-complet*;
}

P_DEFAULTS=" --quiet "
#P_INSTALL+=" ${P_DEFAULTS} "
#P_REMOVE+=" ${P_DEFAULTS} "

_SHELL_TRANSLATOR=1
