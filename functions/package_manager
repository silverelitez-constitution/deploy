# [shayne@vpc ~]$ fortune | cowsay The package cowsay is required to run 'cowsay'! 
# Installing... Okay, now let's try that again...shall we? [shayne@vpc ~]$ cowsay
 # ________________________________________
# / Well, that's more-or-less what I was \
# | saying, though obviously addition is a | little more cosmic than the bitwise | 
# | operators.  |
# |                                        |
# | -- Larry Wall in |
# \ <199709051808.LAA01780@wall.org> /
 # ----------------------------------------
        # \ ^__^
         # \ (oo)\_______
            # (__)\ )\/\
                # ||----w |
                # ||     ||
# [shayne@vpc ~]$
yumr(){
  if sudo yum remove ${@}; then
  echo 'Flushing hash tables...';
    for package in "${@}"; do
      for binary in $(repoquery -l ${package} | grep bin | rev | cut -d'/' -f1 | rev); do
        hash -d ${binary} 2>/dev/null;
      done
    done
  else
    echo 'Package removal failed!'
  fi
}
show-prompt() {
 ExpPS1="$(bash --rcfile <(echo "PS1='$PS1'") -i <<<'' 2>&1 |
     sed ':;$!{N;b};s/^\(.*\n\)*\(.*\)\n\2exit$/\2/p;d')"; echo -n ${ExpPS1}
}
command_not_found_handle () {
	fullcommand="${@}";
	package=$(repoquery --whatprovides "*bin/${1}" -C --qf '%{NAME}' | head -n1);
	if [ ! $package ]; then echo "No package provides ${1}! Command doesn't 
exist..."; return; fi;
	echo "The package ${package} is required to run '${fullcommand}'! Installing..."
	if yum install --quiet -y "${package}"; then
		echo "Okay, now let's try that again...shall we?"
		echo -e "$(show-prompt) ${fullcommand}"
		eval ${fullcommand}
	else
		echo 'Unfortunately the installation failed :('
	fi;
	retval=$?;
	return $retval
}
