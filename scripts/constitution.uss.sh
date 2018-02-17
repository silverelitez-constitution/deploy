echo "Loading domain profile..."

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

setup-git-prompt() {
	echo Loading github bash prompt...
	GIT_PROMPT_ONLY_IN_REPO=1;
	source ~/.bash-git-prompt/gitprompt.sh
}

if [[ ! -d ~/.bash-git-prompt ]]; then 
	cd ~/ && git clone https://github.com/magicmonty/bash-git-prompt.git .bash-git-prompt --depth=1
fi

setup-git-prompt

function unalias() { cmd=${1};  grep -v "alias ${cmd}=" ~/.bash_aliases > ~/.bash_aliases.new; mv ~/.bash_aliases.new ~/.bash_aliases; source unalias "${cmd}";}

cal
fortune
date

which thefuck >/dev/null || eval $(thefuck --alias)

env | grep "^TERM=screen" >/dev/null || screen -R

