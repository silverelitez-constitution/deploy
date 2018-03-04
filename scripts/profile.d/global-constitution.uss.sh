#!/bin/bash
# This deployment script has been lovingly crafted for
DEPLOY_ID="$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | cut -d'"' -f2)"

translation_layer() {
  # Loading translation layer for ${DEPLOY_ID}... 
  #Translation layers will be implemented in the next major merge
  echo "gitsource translator/${DEPLOY_ID}"
}

refresh_global() {
  br=${1:-${branch}}
  branch=${br}
  # Refreshing local global script from ${branch}. development mode stuff...
  domain=$(realm list | head -n1)
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
  if [ ! which thefuck > /dev/null 2>&1 ]; then 
    sudo yum --quiet -y install pip3.4 python34-devel
	sudo pip3.4 install --quiet thefuck
  fi
  [ -e /etc/profile.d/bash_completion.sh ] || sudo yum --quiet --cacheonly -y install *bash-complet*
  if [[ ! -d ~/.bash-git-prompt ]]; then 
    cd ~/ && git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
  fi
}

#translation_layer
refresh_global
check_screen
prep_prompt