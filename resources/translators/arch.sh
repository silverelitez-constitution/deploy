alias i='sudo pacman -S '
P_INSTALL="sudo pacman -S "
P_REMOVE="sudo pacman -Rs "
P_SEARCH() { pacman -Ss "$(@)"; }
P_NAME() { pkgfile -b "$(@)"; }
P_BINARY() { pacman -Fl "$(@)" | grep 'bin/' | cut -d' ' -f2 | rev | cut -d'/' -f1 | rev | sed '/^$/d'; }
P_UPDATES() { pacman -Qu; }
P_UPDATE() { pacman -Syu; }
P_UPGRADE() { pacman -Syu; }
P_INSTALL_PIP() { pacman -S python-pip; }
PG_BASH_COMPLETION() {
  pacman -S bash-completion;
}

P_DEFAULTS=""

_SHELL_TRANSLATOR=1
