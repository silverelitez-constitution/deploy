# If not running interactively, don't do anything
[[ ${-} == *i* ]] || [[ ${1} ]] || return

echo -n "Testing interconnectivity..."
ping -q 4.2.2.2 -c1 >/dev/null || { echo "Failed"; return; } && echo "Done"

F=$(curl -s wttr.in/detroit | grep °F | head -n1 | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | sed 's/[^0-9.]//g')
[ ! ${F} ] && F="93"

# Welcome greeting
echo \
"Good morning and welcome to the Black Mesa Transit System.
This automated train is provided for the security and
convenience of the Black Mesa Research Facility personnel.
The time is $(date +'%I:%M %p'). Current topside temperature
is ${F}°F, with an estimated high of 105°F. The Black Mesa
compound is maintained at a pleasant 68°F at all times."

unset F

# debug
if [ -e /etc/silverelitez/debug ]; then set -x; debug=1; source /etc/silverelitez/debug; fi

# custom configuration
if [ -e /etc/silverelitez/config ]; then source /etc/silverelitez/config; fi

scripts=${@:-head functions aliases global tail}

[ ${debug} ] && echo "Scripts to run: ${scripts}"

[ ! ${domain} ] && { echo -n Reading resolv.conf for domain...;domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2); echo $domain; }
[ ! ${domain} ] && { echo -n Discovering domain...;domain=$(sudo realm discover | head -n1);echo $domain; }




if [ ! ${domain} ]; then
  echo \
  "Thank you for your interest in the Silver Elitez
  Constitution Class single-system beta test. You are receiving
  this message because your domain is not set. This will cause
  the scripts to fail. If you understand that I cannot guarantee
  any form of safety when testing these scripts, then go ahead
  and put 'domain=constitution.uss' in '/etc/silverelitez/config'
  and then re-source the URL."
  echo
  read
  return
fi

# enabling multi-domain system for beta-testers
realm=$(echo ${domain} | cut -d. -f1)
echo "Realm: ${realm}"

if [ ${TESTING_BRANCH} ]; then 
  branch="${TESTING_BRANCH}"
  echo "Testing mode on branch ${branch}"
else
  branch="master"
fi

giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/"

nscripts=$(echo ${scripts} | tr ' ' '\n')
scripts="${nscripts}"
unset nscripts

[ ${debug} ] && echo "${scripts}"

for script in ${scripts}
do
  url="${giturl}${script}-${domain}.sh"
  [ ${debug} ] && { echo Press enter to execute "${url}"; read; }
  output=$(curl -f -s "${url}")
  [ ${?} == '0' ] || output="echo ERROR: curl returned ${?} for ${url}" && source <(echo ${output})
  #source <( curl -s "${url}" | sed 's/^404:.*/echo 404 error/g' | sed 's/^400:.*/echo 400 error/g'; )
done 
