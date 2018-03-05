alias i='sudo emerge --quiet '
P_INSTALL="emerge --keep-going "
P_NAME() { e-file ${1} | sed 's/\x1b\[[0-9;]*m//g' | grep --color=never -n '/' | grep -e '1:\|Matched Files:' | tr '\n' ',' | grep "bin/${1}" | cut -d',' -f1 | sed 's/1: \*//g' | cut -d' ' -f2- | sed 's/^ *//g'; }
P_REMOVE="emerge -Cav "
P_BINARY() { equery files ${1}| grep 'bin/' | rev | cut -d'/' -f1 | rev; }