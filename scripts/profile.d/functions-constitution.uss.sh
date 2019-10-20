# - Global script functions

[ ${debug} ] && echo -n "Loading functions..."

deployer() {
  # replace with "cat $0basenamethingy | grep 'PACKAGES_' | cut -d'_' -f2" to auto scan for functions to run. probably use that for the custom packages
  stages="init preinstall install postinstall configure tail"
  domain=constitution.uss

  gitsource() {
    script=${1:-default.sh}
    branch=${2:-master}
    [ ! $domain ] && domain=$(sudo grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
    realm=$(echo ${domain} | cut -d. -f1)
    gitsurl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/${script}"
    echo ${gitsurl}
    source <(curl -s ${gitsurl} | sed 's/^404:.*/echo 404 error - ${gitsurl}/g'  || echo echo Error)
  }

  _init(){ :;}
  _preinstall(){ :;}
  _install(){ :;}
  _postinstall(){ :;}
  _configure(){ :;}
  _tail(){ :;}

  gitsource "packages/${2}"

  PACKAGE_init() { echo Init...
          [ ! "${svc}" ] && svc=$(basename "$0"| cut -d. -f1)
    #svc=${${svc}:-$(basename "$0"| cut -d. -f1)}
          [ "${svc}" == 'default' ] && svc="${2}"
    #case ${svc} in; default) svc="${2}";; esac
          service="${svc}"

    echo "Setting up ${svc}..."

          src=/etc/silverelitez/debug; [ -e ${src} ] && { set -x; debug=1; source ${src}; }
          src=/etc/silverelitez/config; [ -e ${src} ] && source ${src}
          source /etc/os-release

          echo -n Check for sudo/root...
          if [[ ${SUDO_USER} ]] || [[ ${USER} == 'root' ]]; then
            echo Success;
          else
            echo "Failed for ${USER}"
            echo "Executing script as root..."
            sudo ${0} ${@} || exit 1
            exit
          fi
          if [[ ${TESTING_BRANCH} ]]; then
            branch="${TESTING_BRANCH}"
            echo "Testing mode on branch ${branch}"
          else
            branch="master"
          fi

          echo Hostname: $(hostname | cut -d'.' -f1)
          #if [[ "$(hostname | cut -d'.' -f1)" != "${svc}" ]]; then echo "Can only be deployed to the ${svc} server. Aborting.."; return; fi
          [ ! $domain ] && { echo -n Discovering domain...;domain=$(sudo realm discover | head -n1);echo $domain; }
          [ ! $domain ] && { echo -n Reading resolv.conf for domain...;domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2); echo $domain; }
          [ ! $domain ] && { echo "Could not determine domain name. Fatal Error!"; exit; }
          realm=$(echo ${domain} | cut -d. -f1)
          echo "Realm: ${realm}"
          tld=$(echo ${domain} | cut -d. -f2)
          echo "TLD: ${tld}"
          echo "Initializing functions..."
          giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/functions-${domain}.sh"
          [ $debug ] && echo Executing "${giturl}"
          source <( curl -s "${giturl}" | sed 's/^404:.*/echo 404 error - ${giturl}/g' | sed 's/^400:.*/echo 400 error - ${giturl}/g' ; )

          echo "Loading translation layer..."
          translation_layer
    _init
      # run package-defined check to see if package is already installed and/or configured
    echo "Testing system for package evaluation..."
    [ "${test}" ] && ${test} && exit;
  }
  PACKAGE_preinstall() { echo Preinstall...
    _preinstall;
  }
  PACKAGE_install() { _install;
          echo "Installing packages and software..."
          [ "${packages}" ] && P_INSTALL ${packages}
          [ "${software}" ] && P_INSTALL ${software}
  }
  PACKAGE_postinstall() { _postinstall;
  }
  PACKAGE_configure() { _configure;
          echo "Configuring ${svc}..."

          #is it backed up? no? back it up. yes? delete it
          # cd /etc/; [ ! -e /etc/${svc}.distro ] && mv ${svc} ${svc}.distro || rm -rf /etc/powerdns
          # cd /usr/src
          # [ -e config ] && rm -rf config

          # git clone https://github.com/silverelitez-constitution/config.git
          # cd config
          # cp --preserve=links -r ${svc} /etc

          echo "Starting services..."
          #service httpd restart || { echo "Error. Aborting!"; exit 1; }
          [ "${services}" ] && for service in ${services}; do
      systemctl enable ${service}
      service ${service} restart; done
  }
  PACKAGE_tail() { _tail;
    [ "${test}" ] && ${test} && exit || exit 1;
  }

  # Run provisioning stages
  for stage in ${stages}; do PACKAGE_${stage} "${@}"; done

  echo "The End."
}

tube() { # tube https://example.com/supercoolvideo
  # input
  url="${@}"
  # ensure counter is 0
  i=0
  # keep looping as long as the download fails or the counter is less than 10
  while ! youtube-dl "${url}" && [[ ${i} -lt '10' ]]; do
    # increment the counter
    ((i++))
    # output the counter
    echo "Attempt ${i} of 10"
    # wait 1 second between attempts
    sleep 1
  done
}

tuber() {
  youtube-dl -x --audio-format mp3 ${@};
}

chances() {
  command="${@}"
  # Kindergarten Teacher Mode
  chances="3"
  for i in $(seq ${chances}); do 
    # Matt's bashy comedy hour presents:
    ${command} && return || fuck
  done
}

translation_layer() {
  # Loading translation layer for ${DEPLOY_ID}... 
  #Translation layers have been finally implemented! Beta testing welcomed!!
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
function unmka() { cmd=${1};  grep -v "alias ${cmd}=" ~/.bash_aliases > ~/.bash_aliases.new; mv ~/.bash_aliases.new ~/.bash_aliases; source unalias "${cmd}";}

# just restarted a vps? use this and once it's ready for you, you'll be ready for it (within one second)
function sshw() { while ! ssh "${@}"; do sleep 1; done }

# alpha function to run a script straight from git from the prompt. testing and streamlining for better git-sh scripting
function gitsource() {
  script=${1:-default.sh}
  branch=${2:-master}
  [ ! $domain ] && domain=$(sudo grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
  realm=$(echo ${domain} | cut -d. -f1)
  gitsurl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/${script}"
  source <(curl -s ${gitsurl} | sed 's/^404:.*/echo 404 error - ${gitsurl}/g' || echo echo Error)
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
command_not_found_handle() {
  fullcommand="${@}";
  #package=$(repoquery --whatprovides "*bin/${1}" -C --qf '%{NAME}' | head -n1);
  echo "Command not found: ${1}"
  declare | grep 'P_NAME ()' >/dev/null || exit 1
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

# remove package/binary and flush the hash tables before the fuzz finds it!
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
seenet() {
  watch --interval=0.5 'netstat -aupt | grep -e "ESTABLISH\|LISTEN\|TIME_WAIT"'
}

refresh() {
  [ ${realm} ] || [ ${branch} ] || { echo This guitar is missing strings; return 1; }
  refreshurl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/global.sh"
  [ ${debug} ] && echo "${scripts}"
  [ ${debug} ] && { echo Press enter to execute "${url}"; read; }
  output=$(curl -f -s "${refreshurl}")
  [ ${?} == '0' ] || output="echo ERROR: curl returned ${?} for ${url}" && source <(echo "${output}")
}

[ ${debug} ] && echo "Done!"

myip() {
  curl ipinfo.io/ip
}

seelog() {
  sudo tail -f /var/log/messages /var/log/secure /var/log/{httpd,apache2}/{access,error}_log
}

oui() {
  OUI=$(ip addr list|grep -w 'link'|awk '{print $2}'|grep -P '^(?!00:00:00)'| grep -P '^(?!fe80)' | tr -d ':' | head -c 6)
  curl -sS "http://standards-oui.ieee.org/oui.txt" | grep -i "$OUI" | cut -d')' -f2 | tr -d '\t'
}