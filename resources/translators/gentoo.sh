alias i='sudo emerge --quiet '
P_INSTALL="emerge --keep-going "
P_NAME() {
  [ ${1} == 'fortune' ] && { name='fortune-mod'; } || { name=$(e-file ${1} | sed 's/\x1b\[[0-9;]*m//g' | grep --color=never -n '/' | grep -e '1:\|Matched Files:' | tr '\n' ',' | grep "bin/${1}" | cut -d',' -f1 | sed 's/1: \*//g' | cut -d' ' -f2- | sed 's/^ *//g'; ); }
  [ ${name} ] || name=$(grep  "bin/${1} " /var/db/pkg/*/*/CONTENTS | cut -d'/' -f6 | sed 's/^/=/g')
  echo "${name}";
}
P_REMOVE="emerge -Cav "
P_BINARY() { equery files ${1}| grep 'bin/' | rev | cut -d'/' -f1 | rev; }
P_INSTALL_PIP() { sudo emerge --quiet pip gcc python-dev; }
P_UPDATES() { emerge -NDup world --quiet; }
PG_BASH_COMPLETION() { eval sudo ${P_INSTALL} $(eix *bash-complet* | grep '/' | cut -d' ' -f2- | grep -v -e '^ '); }
P_UPDATE() { sudo emerge --sync --quiet; }
P_UPGRADE() { sudo emerge -NDuav world; revdep-rebuild -i; }

_SHELL_TRANSLATOR=1