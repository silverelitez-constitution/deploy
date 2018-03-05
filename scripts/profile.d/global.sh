# If not running interactively, don't do anything
[[ $- == *i* ]] || return

# debug
set -x;

domain=$(grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
realm=$(echo ${domain} | cut -d. -f1)
if [[ $(hostname) == "testing" ]]; then 
  branch="testing"
  echo Testing mode
else
  branch="master"
fi

giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/"

for script in head functions aliases global tail
do
  echo Executing "${giturl}${script}-${domain}.sh"
  source <(curl -s "${giturl}${script}-${domain}.sh" | sed 's/^404:.*/echo 404 error/g' | dos2unix )
done
