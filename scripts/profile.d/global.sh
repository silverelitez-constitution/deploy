# If not running interactively, don't do anything
[[ $- == *i* ]] || return

domain=$(realm list | head -n1)
realm=$(echo ${domain} | cut -d"." -f1)
#branch="master"
branch="profile.d"

giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/"

for script in head functions aliases global tail
do
  source <(curl -s "${giturl}${script}-${domain}.sh" | dos2unix )
done
