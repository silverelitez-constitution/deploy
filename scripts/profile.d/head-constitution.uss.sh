PATH+=":/usr/games/"
#sudo ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime
sudo echo "Elevated!"
which ntpdate 1&>/dev/null && sudo ntpdate time.windows.com > /dev/null &
