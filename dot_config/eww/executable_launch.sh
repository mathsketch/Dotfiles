#!/usr/bin/bash
# windows=("title_bar" "wm_bar" "date_bar" "side_bar" "info_bar" "music_bar")
windows=("topbar")
scripts="$HOME/.config/eww/scripts"
cache_dir="$HOME/.cache/eww"
# export LC_ALL=en_US.UTF-8

[ -d "$cache_dir" ] || mkdir -p "$cache_dir"

if ! eww ping &>/dev/null;then
    for window in "${windows[@]}";do
        eww open "$window"
    done
else
    "$scripts"/toggleww close
    eww close-all
    ewindows=$(eww windows)
    for window in "${windows[@]}";do
        wd=$(echo "$ewindows" | grep "$window")
        [ "${wd:0:1}" != '*' ] && eww open "$window"
    done
    eww reload
fi
