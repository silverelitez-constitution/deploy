# If not running interactively, don't do anything
[[ $- == *i* ]] || return

which screen >/dev/null || package_installer screen

which nmap >/dev/null || package_installer nmap
which gcc >/dev/null || package_installer gcc
which git >/dev/null || package_installer git
if [[ ! -d ~/deploy ]]; then cd ~/ && git clone git@github.com:silverelitez-constitution/deploy.git; else cd ~/deploy && git checkout master && git pull || git reset --hard HEAD^ && git pull; git checkout -; cd ~/; fi
which fortune >/dev/null || package_installer fortune-mod
which thefuck >/dev/null || echo "$(package_installer python-devel python2-pip && sudo pip install --upgrade pip && sudo -H pip install thefuck)"
