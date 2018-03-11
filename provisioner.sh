#!/bin/bash
# This deployment script has NOT been ravenously tested on:
# Centos 7, Ubuntu 17.10, Gentoo 17.1

# Resources
function gitcat() {
  script=${1:-default.sh}
  [ ! $domain ] && domain=$(sudo grep '^search \|^domain ' /etc/resolv.conf | head -n1 | cut -d' ' -f2)
  realm=$(echo ${domain} | cut -d. -f1)
  gitcurl="https://raw.githubusercontent.com/silverelitez-${realm}/deploy/master/${script}"
  curl -s ${gitcurl} | dos2unix || echo echo Error;
}

provisioner="/tmp/${domain}-provision-${RANDOM}"
gitcat resources/provisioner-${domain}.sh > ${provisioner}
chmod a+x ${provisioner}
/bin/bash ${provisioner} ${1} #&& rm ${provisioner}