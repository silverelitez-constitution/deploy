#!/bin/bash
# This deployment script has been lovingly crafted for 
source /etc/os-release

translation_layer() {
  # Loading translation layer for ${DEPLOY_ID}... 
  #Translation layers will be implemented in the next major merge
  gitsource resources/translators/${ID}.sh
  gitsource resources/translators/default.sh
}

# Refreshing local global script from ${branch}. development mode stuff...
refresh_global() {
  br=${1:-${branch}}
  branch=${br}
  #domain=$(realm list | head -n1)
  domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
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
	P_INSTALL_PIP
	sudo pip3.4 install --user --quiet thefuck;
  fi
  [ -e /etc/profile.d/bash_completion.sh ] || sudo yum --quiet --cacheonly -y install *bash-complet*
  if [[ ! -d ~/.bash-git-prompt ]]; then 
    cd ~/ && git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
  fi
}

translation_layer
refresh_global
check_screen
prep_prompt