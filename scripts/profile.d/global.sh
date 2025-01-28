#!/bin/bash
# If not running interactively, don't do anything
[[ "${-}" == *i* ]] || [[ "${1}" ]] || return

# Ensure the system can reach the internet so there's no lag during the priming process
echo -n "Testing interconnectivity..."
ping -q 8.8.8.8 -c1 >/dev/null || ping -q 1.1.1.1 -c1 >/dev/null || { echo "Failed"; return; } && echo "Done"

# Get the weather
F=$(curl -s wttr.in/detroit | grep °F | head -n1 | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | sed 's/[^0-9.]//g' | sed 's/^..//g' | sed 's/\.\./-/g')
[[ ! "${F}" ]] && F="93"

# Welcome greeting
echo \
"Good morning and welcome to the Black Mesa Transit System.
This automated train is provided for the security and
convenience of the Black Mesa Research Facility personnel.
The time is $(date +'%I:%M %p'). Current topside temperature
is ${F}°F, with an estimated high of 105°F. The Black Mesa
compound is maintained at a pleasant 68°F at all times."

unset F

CURRENTPATH=`pwd`
debug='';

# debug
if [ -e /etc/silverelitez/debug ]; then set -x; debug=1; source /etc/silverelitez/debug; fi

# custom configuration
if [ -e /etc/silverelitez/config ]; then source /etc/silverelitez/config; fi

scripts=${@:-head functions aliases global tail}

[ "${debug}" ] && echo "Scripts to run: ${scripts}"

[[ ! "${domain}" ]] && { echo -n Reading resolv.conf for domain...;domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2); echo $domain; }
[[ ! "${domain}" ]] && { echo -n Discovering domain...;domain=$(sudo realm discover | head -n1);echo $domain; }




if [[ ! "${domain}" ]]; then
  echo \
  "Thank you for your interest in the Silver Elitez
  Constitution Class single-system beta test. You are receiving
  this message because your domain is not set. This will cause
  the scripts to fail. If you understand that I cannot guarantee
  any form of safety when testing these scripts, then go ahead
  and put 'domain=constitution.uss' in '/etc/silverelitez/config'
  or have your DHCP server set your domain name to the one matching
  the git repository you're testing from and then re-source the URL."
  echo
  read
  return
fi

# enabling multi-domain system for beta-testers
realm=$(echo ${domain} | cut -d. -f1)
echo "Realm: ${realm}"

if [[ "${TESTING_BRANCH}" ]]; then 
  branch="${TESTING_BRANCH}"
  echo "Testing mode on branch ${branch}"
else
  branch="master"
fi

giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/"
localpath="/etc/silverelitez/deploy/scripts/profile.d/"

if [[ $localscripts == true ]]; then
  if [ ! -f /etc/silverelitez/deploy/.git/index ]; then
    cd /etc/silverelitez/ && sudo git clone https://github.com/silverelitez-constitution/deploy.git
    sudo chmod a+r deploy -R
  else
    cd /etc/silverelitez/deploy && sudo git reset --hard && sudo git pull
    sudo chmod a+r ../deploy -R
  fi
fi

nscripts=$(echo ${scripts} | tr ' ' '\n')
scripts="${nscripts}"
unset nscripts

[[ "${debug}" ]] && echo "${scripts}"

for script in ${scripts}
do
  url="${giturl}${script}-${domain}.sh"
  scr="${localpath}${script}-${domain}.sh"
  if [[ "${localscripts}" == true ]]; then 
    [[ "${debug}" ]] && { echo Press enter to execute "${scr}"; read; }
    source <(cat ${scr} | dos2unix)
  else
    [[ "${debug}" ]] && { echo Press enter to execute "${url}"; read; }
    output=$(curl -f -s "${url}")
    [[ "${?}" == '0' ]] || output="echo ERROR: curl returned ${?} for ${url}" && source <(echo "${output}")
  fi
done 
cd "${CURRENTPATH}"
