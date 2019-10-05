PATH+=":/usr/games/"
sudo ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime
which ntpdate && ntpdate time.windows.com &