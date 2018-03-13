#source /etc/os-release

# echo -n Check for sudo/root...
# if [[ ${SUDO_USER} ]] || [[ ${USER} == 'root' ]]; then
	# echo Success
# else
	# echo "Failed for ${USER}"
	# echo "Executing script as root..."
	# sudo ${0} ${@} || exit 1
	# exit
# fi

#src=/etc/silverelitez/debug; [ -e ${src} ] && { set -x; debug=1; source ${src}; }
#src=/etc/silverelitez/config; [ -e ${src} ] && source ${src}

if [[ ${TESTING_BRANCH} ]]; then 
  branch="${TESTING_BRANCH}"
  echo "Testing mode on branch ${branch}"
else
  branch="master"
fi

echo Hostname: $(hostname | cut -d'.' -f1)
if [[ "$(hostname | cut -d'.' -f1)" != "dns" ]]; then echo "Can only be deployed to the dns server. Aborting.."; exit; fi

[ ! $domain ] && { echo -n Discovering domain...;domain=$(sudo realm discover | head -n1);echo $domain; }
[ ! $domain ] && { echo -n Reading resolv.conf for domain...;domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2); echo $domain; }
[ ! $domain ] && { echo "Could not determine domain name. Fatal Error!"; exit; }

echo "Initializing functions..."

giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/profile.d/scripts/functions-${domain}.sh"
#[ $debug ] && 
echo Executing "${giturl}"
source <( curl -s "${giturl}" | sed "s/^404:.*/echo 404 error - ${giturl}/g" | sed "s/^400:.*/echo 400 error/g" | dos2unix; )

echo "Loading translation layer..."
translation_layer

echo "Installing power dns service..."
P_INSTALL powerdns

