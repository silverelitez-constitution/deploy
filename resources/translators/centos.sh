alias i='sudo yum -y install '
P_INSTALL="yum -t install -y "
P_NAME() { repoquery --cache  -C --qf %{NAME} --whatprovides *bin/${1}; }
P_REMOVE="yum remove -t "
P_BINARY() { repoquery -l ${1} | grep bin | rev | cut -d'/' -f1 | rev; }
