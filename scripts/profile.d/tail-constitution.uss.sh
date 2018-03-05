#!/bin/bash
export EDITOR='/usr/bin/nano'

GIT_PROMPT_ONLY_IN_REPO=1;
source ~/.bash-git-prompt/gitprompt.sh

eval $(thefuck --alias)

domain=$(sudo realm list | head -n1)
realm=$(echo ${domain} | cut -d"." -f1)
branch="master"
motd="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/resources/etc/motd"

curl -s ${motd} | sed 's/^404:.*/echo 404 error/g' | sed 's/^400:.*/echo 400 error/g' | dos2unix

cal
fortune
date

groups=$(id $(whoami) | sed 's/,/\n/g' | grep -oe "(.*)")

echo "${groups}" | grep --color=never -e 'admin\|user' >/dev/null && num_updates=$(yum list updates | grep epel | grep -v '* epel:' | cut -d' ' -f1 | wc -l) && echo ${num_updates} updates available.
