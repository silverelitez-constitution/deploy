#!/bin/bash
#logfile=$$.log

file=${1:-"gentoo/terraform.tfvars"}
source "${file}"

ih=0
iw=0
pw=0
ph=0

info() {
  dialog --infobox "${@}" $ih $iw
}

msg() {
  dialog --msgbox "${@}" $ih $iw
}
program() { read input
  echo input | dialog --progressbox test ${ph} ${pw}
}

menu() {
  file=${1:-"gentoo/terraform.tfvars"}
  source "${file}"
  oldifs="${IFS}"
  IFS=$'\n'
  ar=()
  i=0
  for line in $(cat "${file}")
  do
  tag=$(echo "${line}" | cut -d'=' -f1 )
  item=$(echo "${line}" | cut -d'=' -f2-)

  i=$((${i}+1))
  image=$(echo ${url} | rev | cut -d'/' -f1 | rev)
  ar+=(${tag} ${item})
  done
  IFS="${oldifs}"
  dialog --stdout --title "${1}" \
		--menu "Please choose Image:" 0 0 0 "${ar[@]}"
}

rlist() {
  file=${1:-"gentoo/terraform.tfvars"}
  oldifs="${IFS}"
  IFS=$'\n'
  ar=()
  i=0
  for line in $(cat "${file}")
  do
  tag=$(echo "${line}" | cut -d'=' -f1 )
  item=$(echo "${line}" | cut -d'=' -f2-)

  i=$((${i}+1))
  image=$(echo ${url} | rev | cut -d'/' -f1 | rev)
  ar+=(${tag} ${item} $([ "${item}" == "${value}" ] && echo -n on || echo -n off))
  done
  IFS="${oldifs}"
  dialog --stdout --title "Image list" \
		--radiolist "Please choose Image:" 0 0 0 "${ar[@]}"
}

item() { tag="${@}"
  if [ -e "${tag}" ]; then type=$(head "${tag}" -n1); fi
  [ ! "${type}" ] && value=$(input "${tag}")
  [ ! "${value}" ] && value="auto"
  eval ${tag}="${value}"
  msg "${tag}=\"${!tag}\""
}

input() { tag="${1}"
  dialog --inputbox --stdout "${tag}" 0 0 "${!tag}"
}

menu="${service}/terraform.tfvars"

while [ "${menu}" ]
do
  item $(menu "${@}")
done