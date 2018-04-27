#!/bin/bash

source defaults
output="firstrun"

main() {
	case $OS in
		1) FOS="Centos 7";;
		2) FOS="Ubuntu 17.1";;
		3) FOS="Gentoo";;
	esac
	output=$(
		dialog --stdout --title "Service Configuration" \
		--menu "Please choose setting to change:" 22 65 20 \
			1 "OS - $FOS" \
			2 "CPU - $CPU" \
			3 "RAM - $RAM" \
			4 "Disk Space - $DISK" \
			5 "Service - ${SERVICE}" \
			6 "Name - ${NAME}" \
			7 "Zone - ${ZONE}" \
			8 "Save and/or Exit"
		)
	echo output $output

	case $? in 
		0) echo code $?
			case $output in
			1) os;;
			2) cpu;;
			3) ram;;
			4) disk;;
			5) service;;
			6) name;;
			7) zone;;
			8) save_exit;;
			?) echo wat;;
		esac
		;;
		1) echo ONE
		;;
		255) echo ERR
		;;
	esac
}

os() {
	os=$(
		dialog --stdout --title "$output" \
		--radiolist "Please choose $output:" 15 55 5 \
			1 "Centos 7" $(if [ $OS == "1" ]; then echo "on"; else echo off; fi) \
			2 "Ubuntu 17.1" $(if [ $OS == "2" ]; then echo "on"; else echo off; fi) \
			3 "Gentoo" $(if [ $OS == "3" ]; then echo "on"; else echo off; fi)
		)
	OS=$os
}

save_exit() { dialog --title "Alert" \
	--yesno "\n Save settings as default?\n Warning: This will cause a full drift scan and auto-correct on current infrastructure!!" 9 50
	exit
}

while [ "${?}" != "1" ] && [ "${output}" != "" ] || [ "${output}" == "firstrun" ]
do
	main
done

save_exit