#if [ -e ]

domain=$(realm list | head -n1)
realm=$(echo ${domain} | cut -d. -f1)
branch="master"

giturl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/${branch}/scripts/profile.d/${realm}/"

curl "${giturl}/global-${domain}.sh"
curl "${giturl}/aliases-${domain}.sh"
curl "${giturl}/functions-${domain}.sh"
