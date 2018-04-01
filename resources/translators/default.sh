#!/bin/bash
# This deployment script has been lovingly crafted for
# Gentoo, Centos, Ubuntu

# System ID
echo "You're using ${PRETTY_NAME}"
echo "OS ID: ${ID}"
echo "Visit us at ${HOME_URL}"
echo "Got a problem? Let us know at ${BUG_REPORT_URL}"

gitsource resources/translators/${ID}.sh
[ ${_SHELL_TRANSLATOR} ] || { echo "Translator load error"; return 1; }

P_INSTALL() { ${P_INSTALL} "${@}"; }
P_REMOVE() { ${P_REMOVE} "${@}"; }
