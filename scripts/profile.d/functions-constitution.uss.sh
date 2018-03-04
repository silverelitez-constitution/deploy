# temporary function to test overall auto-deploy manager
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
	declare $(grep '^DEPLOY_ID=' packages/${service}.sh | sed 's/"//g')
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
	cd ~/deploy && scp packages/${service}.sh ${host}:~/ && ssh -oBatchMode=yes ${host} "~/${service}.sh && rm ${service}.sh"
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
  domain=$(realm list | head -n1)
  realm=$(echo ${domain} | cut -d. -f1)
  giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/${script}"
  echo 'source <(curl -s ${giturl} | dos2unix)'
}

# install packages as you go. no need to mess with package managers
command_not_found_handle () {
    fullcommand="${@}";
    package=$(repoquery --whatprovides "*bin/${1}" -C --qf '%{NAME}' | head -n1);
    if [ ! $package ]; then
        echo "No package provides ${1}! Command doesn't exist...";
        return;
    fi;
    echo -n "The package ${package} is required to run '${fullcommand}'! Installing...";
    if sudo yum install --quiet -y "${package}"; then
		echo "Done!";
        echo "Okay, now let's try that again...shall we?";
        echo -e "$(show-prompt) ${fullcommand}";
        eval ${fullcommand};
    else
        echo "Err!";
		echo 'Unfortunately the installation failed :(';
    fi;
    retval=$?;
    return $retval
}

# oddly, it's kinda hard to properly echo the bash prompt. this seems to do the magic
show-prompt() {
    ExpPS1="$(bash --rcfile <(echo "PS1='$PS1'") -i <<<'' 2>&1 |
     sed ':;$!{N;b};s/^\(.*\n\)*\(.*\)\n\2exit$/\2/p;d')";
    echo -n ${ExpPS1}
}

# quick way to remove a package. next merge will implement binary reference instead of just package
yumr() {
    if sudo yum remove ${@}; then
        echo 'Flushing hash tables...';
        for package in "${@}";
        do
            for binary in $(repoquery -l ${package} | grep bin | rev | cut -d'/' -f1 | rev);
            do
                hash -d ${binary} 2> /dev/null;
            done;
        done;
    else
        echo 'Package removal failed!';
    fi
}