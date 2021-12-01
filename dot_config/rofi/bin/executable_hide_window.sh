#!/usr/bin/bash
DIR="$HOME/.config/rofi"
CACHEDIR="$HOME/.cache/rofi/thumbnail"
ROFI_THEMEDIR="$DIR/themes"
rofi_cmd="rofi -theme $ROFI_THEMEDIR/window.rasi -dmenu -markup-rows -show-icons"
# rofi_msg="rofi -theme $ROFI_THEMEDIR/message.rasi -e"

if ! [ -d "$CACHEDIR" ];then
    mkdir -p "$CACHEDIR"
fi

hide_window() {
    id=$(bspc query -N -n focused)
    maim -u -i "$id" "${CACHEDIR}/${id}.png"
    bspc node "$id" --flag hidden
}

clean() {
    id=$1
    if [ -f "${CACHEDIR}/${id}.png" ];then
        rm "${CACHEDIR}/${id}.png"
    fi
}

show() {
    id=$1
    [ -z "$id" ] && exit 1;
    echo "$id" | while read -r line;do
        bspc node "$line" --flag hidden=off -f --state floating
        clean "$line"
    done
}

rofi_menu() {
    id=$(bspc query -N -n '.hidden.window.local.!marked' | while read -r id;do
        instance=$(xprop -id "$id" | awk -F "=|," '{if($1~/^WM_CLASS/){print $2}}' | awk -F '"|"' '{print tolower($2)}')
        title=$(xprop -id "$id" | awk -F "=|," '{if($1~/^WM_NAME/){print $2}}' | awk -F '"|"' '{print tolower($2)}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        echo -en "<span size='large' weight='bold'>${instance} -- ${title}</span>\n<i>${id}</i>\0icon\x1f${CACHEDIR}/$id.png\r"
    done | $rofi_cmd -format 'p' -p " " -sep '\r' -multi-select | sed -n 'n;p')
    [ -n "$id" ] && show "$id"
}

show_winodw() {
    num=$(bspc query -N -n '.hidden.window.local.!marked' | sed -n '$=')
    [ -z "$num" ] && exit 1
    if [ "$num" -gt 1 ];then
        rofi_menu
    else
        show "$(bspc query -N -n 'any.hidden.window.local.!marked')"
        rm -f "${CACHEDIR}"/*
        echo 'clean'
    fi  
}

main() {
    case "$@" in
        hide) hide_window ;;
        show) show_winodw ;;
    esac
}
main "$@"
