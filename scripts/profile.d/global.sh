# If not running interactively, don't do anything
[[ $- == *i* ]] || return

# debug
if [ -e /etc/debug ]; then set -x; debug=1; source /etc/debug; fi

# custom configuration
if [ -e /etc/config ]; then source /etc/config; fi

domain=$(sudo realm list | head -n1)

if [ ! $domain ]; then
  echo "Hello and thank you for your interest in the Silver Elitez"
  echo "Constitution Class single-system beta test. You are receiving"
  echo "this message because your domain is not set. This will cause"
  echo "the scripts to fail. If you understand that I cannot guarantee"
  echo "any form of safety when testing these scripts, then go ahead"
  echo "and put 'domain=constitution.uss' in '/etc/config'"
  read
  return
fi

# enabling multi-domain system for beta-testers
[ ! $domain ] && domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
realm=$(echo ${domain} | cut -d. -f1)
if [ ${TESTING_BRANCH} ]; then 
  branch="${TESTING_BRANCH}"
  echo "Testing mode on branch ${branch}"
else
  branch="master"
fi

giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/"

for script in head functions aliases global tail
do
[ $debug ] && echo Executing "${giturl}${script}-${domain}.sh"
  source <(curl -s "${giturl}${script}-${domain}.sh" | sed 's/^404:.*/echo 404 error/g' | sed 's/^400:.*/echo 400 error/g' | dos2unix )
done
