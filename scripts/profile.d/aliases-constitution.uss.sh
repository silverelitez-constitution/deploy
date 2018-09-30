[ -e ~/.bash_aliases ] && source ~/.bash_aliases

alias egrep='egrep --color=auto'
alias fano='sudo nano'
alias fgrep='fgrep --color=auto'
alias fucking='sudo'

alias ga='git commit -a --amend && git push -f'
alias gbr='git branch -r'
alias gad='git add .'
alias gl='git checkout -'
alias gm='git checkout master'
alias gp='git pull'
alias gs='git status'

alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -lah'
alias ls='ls --color=auto'
alias sudo='sudo '
alias vssh="vagrant ssh "
alias vspin="vagrant up && vssh"
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias yum='sudo yum'

alias pr='P_REMOVE'
alias pi='P_INSTALL'
alias pf='P_SEARCH'
alias pu="P_UPDATE"
alias pug="P_UPGRADE"
alias pn="P_NAME"

alias awsenv=". ~/.aws/awsenv"
