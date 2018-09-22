alias i='sudo yum -y install '
P_INSTALL="sudo yum -t install -y "
P_NAME() { repoquery --plugins --cache  -C --qf %{NAME} --whatprovides *bin/${1}; }
P_REMOVE="sudo yum remove -t "
P_BINARY() { repoquery --plugins -l ${1} | grep bin | rev | cut -d'/' -f1 | rev; }
P_INSTALL_PIP() { sudo yum --quiet -y install gcc python34-pip python34-devel python34-setuptools; }
P_UPDATES() { yum list updates | grep epel | grep -v '* epel:' | cut -d' ' -f1; }
P_UPDATE() { sudo yum update -y; }
P_UPGRADE() { sudo yum upgrade -y; }
P_SEARCH() { yum search "${@}"; }
PG_BASH_COMPLETION() {
  yum --quiet --cacheonly -y install *bash-complet*;
}

P_INSTALL+=" --quiet "
P_REMOVE+=" --quiet "

_SHELL_TRANSLATOR=1