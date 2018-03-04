# If not running interactively, don't do anything
[[ $- == *i* ]] || return

domain=$(realm list | head -n1)
realm=$(echo ${domain} | cut -d"." -f1)
if [[ $(hostname) == "testing" ]]; then 
  branch="profile.d"
  echo Testing mode
else  
  branch="master"
fi

giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/"

for script in head functions aliases global tail
do
  echo Executing "${giturl}${script}-${domain}.sh"
  source <(curl -s "${giturl}${script}-${domain}.sh" | dos2unix )
done
