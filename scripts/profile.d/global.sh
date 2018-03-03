domain=$(realm list | head -n1)
realm=$(echo ${domain} | cut -d. -f1)
branch="profile.d"

#giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/${realm}/"
giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/"

for script in global #aliases functions
do
  #echo ${script}
  #eval $(curl ${giturl} | dos2unix | bash)
  #eval $(curl -s "${giturl}${script}-${domain}.sh")
  source <(curl -s "${giturl}${script}-${domain}.sh" | dos2unix )
done
