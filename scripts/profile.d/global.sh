# If not running interactively, don't do anything
[[ $- == *i* ]] || return

echo \
"Good morning and welcome to the Black Mesa Transit System.
This automated train is provided for the security and
convenience of the Black Mesa Research Facility personnel.
The time is $(date +'%I:%M %p'). Current topside temperature
is 93 degrees, with an estimated high of one hundred and five.
The Black Mesa compound is maintained at a pleasant 68 degrees
at all times."

# debug
if [ -e /etc/silverelitez/debug ]; then set -x; debug=1; source /etc/silverelitez/debug; fi

# custom configuration
if [ -e /etc/silverelitez/config ]; then source /etc/silverelitez/config; fi

[ ! $domain ] && { echo -n Discovering domain...;domain=$(sudo realm discover | head -n1);echo $domain; }
[ ! $domain ] && { echo -n Reading resolv.conf for domain...;domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2); echo $domain}

if [ ! $domain ]; then
  echo 
  echo "Thank you for your interest in the Silver Elitez"
  echo "Constitution Class single-system beta test. You are receiving"
  echo "this message because your domain is not set. This will cause"
  echo "the scripts to fail. If you understand that I cannot guarantee"
  echo "any form of safety when testing these scripts, then go ahead"
  echo "and put 'domain=constitution.uss' in '/etc/config' and re-source"
  echo "the url."
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

for script in head functions aliases global tail
do
  [ $debug ] && echo Executing "${giturl}${script}-${domain}.sh"
  source <(curl -s "${giturl}${script}-${domain}.sh" | sed 's/^404:.*/echo 404 error/g' | sed 's/^400:.*/echo 400 error/g' | dos2unix )
done
