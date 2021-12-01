#!/usr/bin/bash
DIR="$HOME/.config/rofi"
CACHEDIR="$HOME/.cache/rofi/"
ROFI_THEMEDIR="$DIR/themes"
rofi_cmd="rofi -theme $ROFI_THEMEDIR/text.rasi -dmenu -p  -selected-row 0 -i"
paste_content=$(greenclip print | $rofi_cmd)
if [ -n "$paste_content" ];then
    greenclip print "$paste_content"
    xdotool key --clearmodifiers "ctrl+shift+v"
fi
