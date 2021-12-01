#!/usr/bin/bash
DIR="$HOME/.config/rofi"
SCRIPTDIR="$DIR/script"
ROFI_THEMEDIR="$DIR/themes"
MODE="$DIR/bin/networkmanager_mode.sh"
CACHEFILE="$HOME/.cache/rofi/nmcli_rofi"

[ -f "$CACHEFILE" ] && rm "$CACHEFILE"

main() {
    connect_wifi() {
        ssid=$(sed -e '2!d' "$CACHEFILE")
        password=$(rofi -dmenu -theme "$ROFI_THEMEDIR/input.rasi" -p 'PASSWORD' -mesg "Please input password for $ssdi" -password)
        [ -z "$password" ] && exit 0

        notify-send "Connecting..."
        rofi -theme "$ROFI_THEMEDIR/message.rasi" -e "$(nmcli device wifi connect "$ssid" password "$password" 2>&1)"

        rm "$CACHEFILE"
    }

    view_status() {
        info=$(nmcli -t | head -n -4)
        rofi -theme "$ROFI_THEMEDIR/message.rasi" -e "$info" -theme-str 'window {width: 30%;location: north;y-offset: 20px;}'

        rm "$CACHEFILE"
        main
    }

    rofi -theme "$ROFI_THEMEDIR/nmcli.rasi" -modi "nmcli:$MODE" -show nmcli -selected-row 0
    [ -f "$CACHEFILE" ] || exit 0

    action=$(cat "$CACHEFILE" | head -n 1)
    case "$action" in
        "connect_wifi") connect_wifi;;
        "view_status") view_status;;
    esac
}
main
