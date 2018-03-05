#!/bin/bash
export EDITOR='/usr/bin/nano'

GIT_PROMPT_ONLY_IN_REPO=1;
source ~/.bash-git-prompt/gitprompt.sh

eval $(thefuck --alias)

echo d
domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
realm=$(echo ${domain} | cut -d"." -f1)
branch="master"
motd="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/resources/etc/motd"

[ $debug ] && echo ${motd}
curl -s ${motd} | sed "s/^404:.*/echo 404 error/g" | sed 's/^400:.*/echo 400 error/g' | dos2unix

cal
fortune
date

groups=$(id $(whoami) | sed 's/,/\n/g' | grep -oe "(.*)")

# portage takes forever to generate update list. disabled during diag/sanity
if [ ${ID} != 'gentoo' ]; then
  echo "${groups}" | grep --color=never -e 'admin\|user' >/dev/null && num_updates=$(P_UPDATES | wc -l) && echo ${num_updates} updates available.
fi
