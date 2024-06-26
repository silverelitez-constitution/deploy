[ -e ~/.bash_aliases ] && source ~/.bash_aliases

alias egrep='egrep --color=auto'
alias fano='sudo nano'
alias fgrep='fgrep --color=auto'
alias fucking='sudo'

alias ga='git commit -a --amend && git push -f'
alias gad='git add .'
alias gadd='git add'
alias gbr='git branch -r'
alias gdiff='git diff'
alias gl='git checkout -'
alias gm='git checkout master'
alias gp='git pull'
alias gs='git status'

alias dmesg='dmesg -T'
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