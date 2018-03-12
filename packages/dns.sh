source /etc/os-release

echo Hostname: $(hostname | cut -d'.' -f1)
if [[ "$(hostname | cut -d'.' -f1)" != "dns" ]]; then echo "Can only be deployed to the dns server. Aborting.."; exit; fi

echo -n Check for sudo...
if [[ ! ${SUDO_USER} ]]; then
	echo "Failed"
	echo "Executing script as root..."
	sudo ${0} ${@} || exit 1
	exit
else
	echo Success
fi

P_INSTALL powerdns

