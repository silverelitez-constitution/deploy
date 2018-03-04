#!/bin/bash
export EDITOR='nano'

# [shayne@vpc ~]$ fortune | cowsay
# The package cowsay is required to run 'cowsay'! Installing...
# Okay, now let's try that again...shall we?
# [shayne@vpc ~]$ cowsay
 # ________________________________________
# / Well, that's more-or-less what I was   \
# | saying, though obviously addition is a |
# | little more cosmic than the bitwise    |
# | operators.                             |
# |                                        |
# | -- Larry Wall in                       |
# \ <199709051808.LAA01780@wall.org>       /
 # ----------------------------------------
        # \   ^__^
         # \  (oo)\_______
            # (__)\       )\/\
                # ||----w |
                # ||     ||
# [shayne@vpc ~]$

GIT_PROMPT_ONLY_IN_REPO=1;
source ~/.bash-git-prompt/gitprompt.sh

echo "thefuck disabled until python2 issue is resolved"
#eval $(thefuck --alias)

domain=$(realm list | head -n1)
realm=$(echo ${domain} | cut -d"." -f1)
branch="master"
motd="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/resources/etc/motd"

curl -s ${motd} | dos2unix

cal
fortune
date

echo -n "You are a member of ";id $(whoami) | sed 's/,/\n/g' | grep -o '(domain admins)' && num_updates=$(yum list updates | grep epel | grep -v '* epel:' | cut -d' ' -f1 | wc -l) && echo ${num_updates} updates available.
