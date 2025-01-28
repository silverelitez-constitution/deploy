#!/bin/bash

if [ ! -e ~/.inputrc ]; then
cat > ~/.inputrc <<EOF
"\e[5~": history-search-backward   
"\e[6~": history-search-forward 
EOF
fi

export EDITOR='/usr/bin/nano'
export PATH="${PATH}:/usr/local/go/bin:${HOME}/go/bin"
export NCURSES_NO_UTF8_ACS=1

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
  which yum-complete-transaction 1&>/dev/null && sudo yum-complete-transaction -y >/dev/null
  if echo "${groups}" | grep --color=never -e 'admin\|user' >/dev/null && [[ -f /etc/updates ]]; then num_updates=$(cat /etc/updates | wc -l)
    echo ${num_updates} updates available.
   [[ ${num_updates} -gt "0" ]] && cat /etc/updates
  fi
fi

check_screen
# allow X11 forwarding while elevated via 'sudo su -'
[ $(whoami) == "root" ] && xauth add $(xauth -f /home/$(logname)/.Xauthority list|tail -1)
DEFAULT=$PS1
PS1="|\`date +%H:%M\`|${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "
echo "Silver layer loaded. Run 'h' to show a help menu"
