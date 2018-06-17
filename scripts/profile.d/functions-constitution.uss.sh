# - Global script functions

[ ${debug} ] && echo "Loading functions..."

chances() {
  command="${@}"
  chances="3"
  for i in `seq ${chances}`; do 
    ${command} && return || fuck
  done
}

translation_layer() {
  # Loading translation layer for ${DEPLOY_ID}... 
  #Translation layers will be implemented in the next major merge
  gitsource resources/translators/default.sh
}

# Refreshing local global script from ${branch}. development mode stuff...
refresh_global() {
  br=${1:-${branch}}
  branch=${br}
  #domain=$(sudo realm list | head -n1)
  [ ! $domain ] && domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
  realm=$(echo ${domain} | cut -d. -f1)
  globalurl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/global.sh"
  curl -s ${globalurl} | dos2unix > ~/.git.global.sh
  sudo cp ~/.git.global.sh /etc/profile.d/global.sh
  sudo chown root.root /etc/profile.d/global.sh
  sudo chmod a+x /etc/profile.d/global.sh
}

check_screen() {
  # Preparing screen...
  env | grep "^TERM=screen" >/dev/null || screen -Rd
}

prep_prompt() {
  if ! which thefuck > /dev/null 2>&1; then 
	${P_INSTALL} expect sshpass
    P_INSTALL_PIP
    pip3.4 install --user --quiet thefuck;
  fi
  [ -e /etc/profile.d/bash_completion.sh ] || [ -e /etc/bash/bashrc.d/bash_completion.sh ] || sudo PG_BASH_COMPLETION
  if [[ ! -d ~/.bash-git-prompt ]]; then 
    cd ~/ && git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
  fi
}

# - User Environment functions

# temporary function to test overall auto-deploy manager
deployer() {
  service=${1}; shift
  password=${1}; shift
  hosts=${@:-${service}}
  if [[ ${hosts} == "all" ]]; then
    echo "Deploying to all hosts. Press enter to continue..."
	read
	hosts="$(nmap 10.37.224.* -sn | grep 'scan report for ' | cut -d' ' -f5)"
  else
	mosts="${hosts}"
	hosts=$(echo "${mosts}" | sed 's/ /\n/g')
  fi
  oldIFS=${IFS}
  IFS=$'\n'
  for host in ${hosts}
  do
	declare "$(ssh -oBatchMode=yes ${host} cat /etc/os-release)"
	echo Host ID is ${ID}
	echo Deploying to ${host}...
    #ping -c1 ${host} >/dev/null && 
	cd ~/deploy && scp packages/${service}.sh ${host}:~/ && ssh -oBatchMode=yes ${host} "~/${service}.sh ${password} && rm ${service}.sh"
  done
  IFS=${oldIFS}
}

# beta function to add an alias to current session and permanently store it as well
# will be adding git sync support in next major merge
mka() {
    shopt -s expand_aliases;
    if [ ! ${1} ]; then
        cat ~/.bash_aliases 2> /dev/null;
        return;
    fi;
    cmd="${1}";
    shift;
    alias="${@}";
    grep --color=never "alias ${cmd}=" ~/.bash_aliases > /dev/null || echo alias "${cmd}"="\"${alias}\"" >> ~/.bash_aliases;
    source ~/.bash_aliases
}

# removes the alias permanently. the yang to the mka() ying, if you will
function unalias() { cmd=${1};  grep -v "alias ${cmd}=" ~/.bash_aliases > ~/.bash_aliases.new; mv ~/.bash_aliases.new ~/.bash_aliases; source unalias "${cmd}";}

# just restarted a vps? use this and once it's ready for you, you'll be ready for it (within one second)
function sshw() { while ! ssh "${@}"; do sleep 1; done }

# alpha function to run a script straight from git from the prompt. testing and streamlining for better git-sh scripting
function gitsource() {
  script=${1:-default.sh}
  branch=${2:-master}
  [ ! $domain ] && domain=$(sudo grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
  realm=$(echo ${domain} | cut -d. -f1)
  gitsurl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/${script}"
  source <(curl -s ${gitsurl} | sed 's/^404:.*/echo 404 error - ${gitsurl}/g' | dos2unix || echo echo Error)
}

function gitcat() {
  script=${1:-default.sh}
  branch=${2:-master}
  [ ! $domain ] && domain=$(sudo grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
  realm=$(echo ${domain} | cut -d. -f1)
  gitcurl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/${script}"
  curl -s ${gitcurl} | dos2unix || echo echo Error;
}

# install packages as you go. no need to mess with package managers
command_not_found_handle () {
  fullcommand="${@}";
  #package=$(repoquery --whatprovides "*bin/${1}" -C --qf '%{NAME}' | head -n1);
  echo "Command not found: ${1}"
  package=$(P_NAME ${1} |head -n1)
  if [ ! $package ]; then
    echo "No package provides ${1}! Command doesn't exist...";
    return;
  fi;
  echo -n "The package ${package} is required to run '${fullcommand}'! Installing...";
  if sudo ${P_INSTALL} "${package}" >/dev/null; then
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
  return $retval;
}

# remove package/binary
r() {
  echo 'Flushing hash tables...';
  for package in "${@}";
  do
    for binary in $(P_BINARY $package);
    do
      hash -d ${binary} 2> /dev/null;
    done;
  done;
  if sudo ${P_REMOVE} ${@}; then
	echo 'Package has been removed!';
  else
    echo 'Package removal failed!';
  fi
}

# oddly, it's kinda hard to properly echo the bash prompt. this seems to do the magic
show-prompt() {
    ExpPS1="$(bash --rcfile <(echo "PS1='$PS1'") -i <<<'' 2>&1 |
     sed ':;$!{N;b};s/^\(.*\n\)*\(.*\)\n\2exit$/\2/p;d')";
    echo -n ${ExpPS1}
}

gc() {
  message=${@}
  git commit -am "${message}" && git push
}

paster() {
  curl -F c=@- https://ptpb.pw; 
}
