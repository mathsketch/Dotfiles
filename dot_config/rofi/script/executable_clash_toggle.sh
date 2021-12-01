#!/usr/bin/bash
if [ "$(systemctl --user is-active clash.service)" = "active" ];then
    systemctl --user stop clash.service
elif [ -n "$(pgrep -x clash)" ];then
    killall clash; sleep 2
    systemctl --user start clash.service
else
    systemctl --user start clash.service
fi
