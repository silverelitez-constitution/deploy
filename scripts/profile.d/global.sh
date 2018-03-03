domain=$(realm list | head -n1)
realm=$(echo ${domain} | cut -d. -f1)
branch="master"

#giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/${realm}/"
giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/"

for script in global aliases functions
do
  echo ${script}
  curl "${giturl}${script}-${domain}.sh"
done
