PATH+=":/usr/games/"
#sudo ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime
sudo true
which ntpdate >/dev/null && sudo ntpdate time.windows.com > /dev/null &
