#!/bin/bash
# This deployment script has been lovingly crafted for
DEPLOY_ID="$(grep 'ID=' /etc/os-release | cut -d'=' -f2 | cut -d'"' -f2)"

refresh_global() {
  echo Refreshing local global script. development mode stuff...
  domain=$(realm list | head -n1)
  realm=$(echo ${domain} | cut -d. -f1)
  branch="master"
  giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/global.sh"
  curl -s ${giturl} | dos2unix > /etc/profile.d/global.sh
}

check_screen() {
  echo "Preparing screen..."
  env | grep "^TERM=screen" >/dev/null || screen -RR
}

translation_layer() {
  echo Loading layer for ${DEPLOY_ID}... 
  echo Translation layers will be implemented in the next major merge
  echo "gitsource translator\${DEPLOY_ID}"
}

prep_prompt() {
echo Bash prompt preperation. Making your life much easier...
  [ -e /etc/profile.d/bash_completion.sh ] || sudo yum --quiet --cacheonly -y install *bash-complet*
  if [[ ! -d ~/.bash-git-prompt ]]; then 
    cd ~/ && git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
  fi
}

refresh_global
check_screen
#translation_layer
prep_prompt