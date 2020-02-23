PATH+=":/usr/games/"
#sudo ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime
which ntpdate >/dev/null && sudo ntpdate time.windows.com > /dev/null &