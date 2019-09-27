#!/bin/bash
export EDITOR='/usr/bin/nano'
export PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"

GIT_PROMPT_START="[\${AWS_ENV}] "

[ ! $GIT_PROMPT_ONLY_IN_REPO ] && GIT_PROMPT_ONLY_IN_REPO=1;
[ ! $GIT_PROMPT_THEME ] && GIT_PROMPT_THEME=TruncatedPwd_WindowTitle_Ubuntu;
source ~/.bash-git-prompt/gitprompt.sh;

[ ${ID} == 'centos' ] && [ -f /etc/yum.repos.d/lux.repo ] || {
  sudo rpm -Uvh http://repo.iotti.biz/CentOS/5/noarch/lux-release-0-1.noarch.rpm;
  sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-LUX;
}

echo "Loading prompt patcher..."
eval $(thefuck --alias)

[ ! $domain ] && domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
realm=$(echo ${domain} | cut -d"." -f1)

motd="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/resources/etc/motd"

[ $debug ] && echo ${motd}
curl -s ${motd} | sed "s/^404:.*/echo 404 error/g" | sed 's/^400:.*/echo 400 error/g' | dos2unix

cal
fortune
date
uptime
uname -a

groups=$(id $(whoami) | sed 's/,/\n/g' | grep -oe "(.*)")

# portage takes forever to generate an update list. disabled during diag/sanity retention
if [[ ${ID} == 'centos' ]] || [[ ${ID} == 'amzn' ]]; then
  sudo yum-complete-transaction -y >/dev/null
  if echo "${groups}" | grep --color=never -e 'admin\|user' >/dev/null; then num_updates=$(P_UPDATES | wc -l)
    echo ${num_updates} updates available.
    [[ ${num_updates} -gt "0" ]] && P_UPDATES
  fi
fi

check_screen
