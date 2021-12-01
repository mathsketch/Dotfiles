#!/bin/bash
WMS=("bspwm" "dwm" "leftwm" "i3" "i3-with-shmlog" "jwm" "openbox" "qtile" "qtile-venv" "xmonad")
if [[ " ${WMS[*]} " = *" $XDG_CURRENT_DESKTOP "* || " ${WMS[*]} " = *" $XDG_SESSION_DESKTOP "* ||
      " ${WMS[*]} " = *" $DESKTOP_SESSION "* ]]; then
    picom &
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
    pgrep -x unclutter || unclutter -b -timeout 5 &
    pgrep fcitx5 || fcitx5 &
    ${HOME}/.fehbg &
    xset s 1200 60;xss-lock -n dim-screen.sh -- screen_lock &
    touchpad_toggle off
    pgrep -x greenclip || greenclip daemon &
    /usr/lib/kdeconnectd &
    echo "autostart finished"
fi
