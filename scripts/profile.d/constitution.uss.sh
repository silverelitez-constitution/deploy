#!/bin/bash
# This deployment script has been lovingly crafted for
DEPLOY_ID="$(grep 'ID=' /etc/os-release | cut -d'=' -f2 | cut -d'"' -f2)"

echo Loading layer for ${DEPLOY_ID}... 
source translator\${DEPLOY_ID}

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

which screen >/dev/null || package_installer screen

echo "Preparing screen..."
env | grep "^TERM=screen" >/dev/null || screen -RR

which nmap >/dev/null || package_installer nmap
which gcc >/dev/null || package_installer gcc
which git >/dev/null || package_installer git
if [[ ! -d ~/deploy ]]; then cd ~/ && git clone git@github.com:silverelitez-constitution/deploy.git; else cd ~/deploy && git checkout master && git pull || git reset --hard HEAD^ && git pull; git checkout -; cd ~/; fi
which fortune >/dev/null || package_installer fortune-mod
which thefuck >/dev/null || echo "$(package_installer python-devel python2-pip && sudo pip install --upgrade pip && sudo -H pip install thefuck)"

function deployer() {
  service=${1}; shift
  hosts=${@}
  if [[ ! ${hosts} ]]; then
    echo "No host(s) specified. Deploying to all."
	hosts="$(nmap 10.37.224.* -sn | grep 'scan report for ' | cut -d' ' -f5)"
  else
	mosts="${hosts}"
	hosts=$(echo "${mosts}" | sed 's/ /\n/g')
  fi
  
  oldIFS=${IFS}
  IFS=$'\n'
  for host in ${hosts}
  do
	declare $(grep '^DEPLOY_ID=' scripts/${service}.sh | sed 's/"//g')
	echo Checking host for depoloyability...
	declare $(ssh -oBatchMode=yes ${host} grep '^ID=' /etc/os-release | sed 's/"//g')
	echo Host ID is ${ID}
	echo Host ID for deployment is ${DEPLOY_ID}
	if [[ ${DEPLOY_ID} -ne ${ID} ]]; then
		echo "Host is not ${DEPLOY_ID}! Skipping."
		return;
	fi
	echo Deploying to ${host}...
    #ping -c1 ${host} >/dev/null && 
	cd ~/deploy && scp scripts/${service}.sh ${host}:~/ && ssh -oBatchMode=yes ${host} "~/${service}.sh && rm ${service}.sh"
  done
  IFS=${oldIFS}
}

mka ()
{
    shopt -s expand_aliases;
    if [ ! ${1} ]; then
        cat ~/.bash_aliases 2> /dev/null;
        return;
    fi;
    cmd="${1}";
    shift;
    alias="${@}";
    grep --color=auto "alias ${cmd}=" ~/.bash_aliases > /dev/null || echo alias "${cmd}"="\"${alias}\"" >> ~/.bash_aliases;
    source ~/.bash_aliases
}

if [[ ! -d ~/.bash-git-prompt ]]; then 
	cd ~/ && git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
fi

echo Loading github bash prompt...
GIT_PROMPT_ONLY_IN_REPO=1;
source ~/.bash-git-prompt/gitprompt.sh

function unalias() { cmd=${1};  grep -v "alias ${cmd}=" ~/.bash_aliases > ~/.bash_aliases.new; mv ~/.bash_aliases.new ~/.bash_aliases; source unalias "${cmd}";}

alias sudo="sudo "
alias fucking=sudo
alias ll='ls -lah'

function sshw () { while ! ssh $1; do sleep 1; done }

cd ~/

eval $(thefuck --alias)

cal
fortune
date

id $(whoami) | sed 's/,/\n/g' | grep '(domain admins)' >/dev/null && num_updates=$(yum list updates | grep epel | grep -v '* epel:' | cut -d' ' -f1 | wc -l) && echo ${num_updates} updates available.
