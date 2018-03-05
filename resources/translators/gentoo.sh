#!/bin/bash
# This deployment script has been lovingly crafted for
source /etc/os-release

echo $NAME
echo $VERSION
echo $ID
echo $ID_LIKE
echo $VERSION_ID
echo $PRETTY_NAME
echo $ANSI_COLOR
echo $CPE_NAME
echo $HOME_URL
echo $BUG_REPORT_URL
echo 
echo $CENTOS_MANTISBT_PROJECT
echo $CENTOS_MANTISBT_PROJECT_VERSION
echo $REDHAT_SUPPORT_PRODUCT
echo $REDHAT_SUPPORT_PRODUCT_VERSION
echo 
# will use case asap!! clean code, clean head.

if [ ${ID} == "gentoo"];
  P_INSTALL="emerge --keep-going "
  
fi

if [ ${ID} == "centos"];
  P_INSTALL="yum -t install -y "
  P_NAME='$(repoquery --whatprovides "*bin/${1}" -C --qf '%{NAME}' | head -n1)'
fi

# Bits that just happen to be common, put them here
P_INSTALL+=" --quiet "


# php detect browser is curl and prints user "shayne" default scripts to be sourced locally. enough to either prepare the prompt for enhancement or just full automatic enhancement instantly. whatever your flavour
#source <(curl shayne.latnokfusion.org)

# install packages as you go. no need to mess with package managers
command_not_found_handle () {
  fullcommand="${@}";
  #package=$(repoquery --whatprovides "*bin/${1}" -C --qf '%{NAME}' | head -n1);
  package=${P_NAME}
  if [ ! $package ]; then
    echo "No package provides ${1}! Command doesn't exist...";
    return;
  fi;
  echo -n "The package ${package} is required to run '${fullcommand}'! Installing...";
  if sudo "${P_INSTALL}" "${package}"; then
	echo "Done!";
    echo "Okay, now let's try that again...shall we?";
    # oddly, it's kinda hard to properly echo the bash prompt. this seems to do the magic
	show-prompt() {
	  ExpPS1="$(bash --rcfile <(echo "PS1='$PS1'") -i <<<'' 2>&1 |
	  sed ':;$!{N;b};s/^\(.*\n\)*\(.*\)\n\2exit$/\2/p;d')";
	  echo -n ${ExpPS1}
	}
	echo -e "$(show-prompt) ${fullcommand}";
    eval ${fullcommand};
  else
    echo "Err!";
	echo 'Unfortunately the installation failed :(';
  fi;
  retval=$?;
  return $retval
}

exit 0

#DEPLOY_ID="gentoo"

# If not running interactively, don't do anything
[[ $- == *i* ]] || return

which screen >/dev/null || sudo yum -y install screen

echo "Preparing screen..."
env | grep "^TERM=screen" >/dev/null || screen -RR

which nmap >/dev/null || sudo yum -y install nmap
which gcc >/dev/null || sudo yum -y install gcc
which git >/dev/null || sudo yum -y install git
if [[ ! -d ~/deploy ]]; then cd ~/ && git clone git@github.com:silverelitez-constitution/deploy.git; else cd ~/deploy && git checkout master && git pull || git reset --hard HEAD^ && git pull; cd ~/; fi
which fortune >/dev/null || sudo yum -y install fortune-mod
which thefuck >/dev/null || echo "$(sudo yum -y install python-devel python2-pip && sudo pip install --upgrade pip && sudo -H pip install thefuck)"

function deployer() {
  service=${1}; shift
  hosts=${@}
  if [[ ! ${hosts} ]]; then
    echo "No host(s) specified. Deploying to all."
	hosts="$(nmap 10.37.224.* -sn | grep 'scan report for ' | cut -d' ' -f5)"
  fi
  oldIFS=${IFS}
  IFS=$'\n'
  for host in ${hosts}
  do
	declare $(grep '^DEPLOY_ID=' scripts/${service}.sh | sed 's/"//g')
	echo Checking host for depoloyability...
	declare $(ssh ${host} grep '^ID=' /etc/os-release | sed 's/"//g')
	echo Host ID is ${ID}
	echo Host ID for deployment is ${DEPLOY_ID}
	if [[ ${DEPLOY_ID} -ne ${ID} ]]; then
		echo "Host is not ${DEPLOY_ID}! Skipping."
		return;
	fi
	echo Deploying to ${host}...
    ping -c1 ${host} >/dev/null && cd ~/deploy && scp scripts/${service}.sh ${host}:~/ && ssh ${host} "~/${service}.sh && rm ${service}.sh"
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

alias fucking=sudo
alias ll='ls -lah'
function sshw () { while ! ssh $1; do sleep 1; done }

cd ~/

eval $(thefuck --alias)

cal
fortune
date

id $(whoami) | sed 's/,/\n/g' | grep '(domain admins)' >/dev/null && num_updates=$(yum list updates | grep epel | grep -v '* epel:' | cut -d' ' -f1 | wc -l) && echo ${num_updates} updates available.


