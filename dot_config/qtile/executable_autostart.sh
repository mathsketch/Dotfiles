#!/usr/bin/bash

xset r rate 300 40 &
picom &
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
pgrep -x unclutter || unclutter -b -timeout 5 &
pgrep fcitx5 || fcitx5 &
"$HOME/.fehbg" &
xset s 1200 60;xss-lock -n dim-screen.sh -- screen_lock &
touchpad_toggle off &
pgrep -x greenclip || greenclip daemon &
# pgrep -x dunst || dunst &
playerctld daemon &
/usr/lib/kdeconnectd &
"$HOME/.config/eww/launch.sh"
