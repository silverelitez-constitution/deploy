echo Loading github bash prompt...
GIT_PROMPT_ONLY_IN_REPO=1;
source ~/.bash-git-prompt/gitprompt.sh

eval $(thefuck --alias)

cal
fortune
date

id $(whoami) | sed 's/,/\n/g' | grep '(domain admins)' >/dev/null && num_updates=$(yum list updates | grep epel | grep -v '* epel:' | cut -d' ' -f1 | wc -l) && echo ${num_updates} updates available.
