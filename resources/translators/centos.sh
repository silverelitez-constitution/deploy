if (which dnf > /dev/null); then

	alias i='sudo dnf -y install '
	P_INSTALL="sudo dnf install -y "
	P_NAME() { repoquery --cache -q -C --qf %{NAME} --whatprovides *bin/${1}; }
	P_REMOVE="sudo dnf remove -y "
	P_BINARY() { repoquery --quiet -l ${1} | grep bin | rev | cut -d'/' -f1 | rev; }
	P_INSTALL_PIP() { sudo dnf --quiet -y install gcc platform-python-pip; }
	P_UPDATES() { dnf list updates | grep epel | grep -v '* epel:' | cut -d' ' -f1; }
	P_UPDATE() { sudo dnf update -y; }
	P_UPGRADE() { sudo dnf upgrade -y; }
	P_SEARCH() { dnf search "${@}"; }
	PG_BASH_COMPLETION() {
		${P_INSTALL} --cacheonly *bash-complet*;
	}

	P_DEFAULTS=" --quiet "

else 

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
fi

_SHELL_TRANSLATOR=1
