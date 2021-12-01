#!/usr/bin/bash
DIR="$HOME/.config/rofi"
ROFI_THEMEDIR="$DIR/themes"
SEPARATION=";"
# TODO
# type eth wifi 
# device ensp3s0 wlo1

initialization() {
    unset actions
    get_device_info
    if [ "$(iw wlo1 info | grep -i type | cut -d ' ' -f 2)" == 'AP' ];then
        actions+=("hotspot" "show password")
    elif [ "${wifi[1]}" != "unavailable" ];then
        actions+=("wifi list" "hotspot")
    fi
    actions+=("wifi toggle" "eth toggle" "status")
    if [ "$(nmcli connection show -a | sed -ne '$=')" -gt 1 ];then
        actions+=("connected list")
    fi
    if [ "$(nmcli connection show  | sed -ne '$=')" -gt 1 ];then
        actions+=("saved connection list")
    fi
    set_row_state
}
set_row_state() {
    for (( i=0; i < ${#actions}; i++ ));do 
        case "${actions[$i]}" in
            "hotspot") 
              [ "$(iw wlo1 info | grep -i type | cut -d ' ' -f 2)" == 'AP' ] \
                && actrow+="$i,"
            ;;
            "wifi toggle") 
              [ "${wifi[1]}" == "connected" ] && actrow+="$i,"
              [ "${wifi[1]}" == "unavailable" ] && urgrow+="$i,"
            ;;
            "eth toggle")
              [ "${eth[1]}" == "connected" ] && actrow+="$i,"
              [ "${eth[1]}" == "unavailable" ] && urgrow+="$i,"
            ;;
        esac
    done
}

get_device_info() {
    device_list=($(nmcli -g DEVICE,TYPE,STATE device status))
    for device in "${device_list[@]}";do
        device_type=$(echo $device | sed -re 's/^.*:(.*):.*$/\1/')
        device_name=$(echo $device | sed -re 's/^(.*):.*:.*$/\1/')
        device_state=$(echo $device | sed -re 's/^.*:.*:(.*)$/\1/')
        if [ "$device_type" == 'wifi' ] ;then
            wifi=("$device_name" "$device_state")
        elif [ "$device_type" == 'ethernet' ];then
            eth=("$device_name" "$device_state")
        fi
    done
}

hotspot_toggle() {
    if [ "$(iw wlo1 info | grep -i type | cut -d ' ' -f 2)" == 'AP' ];then
        nmcli device disconnect "${wifi[0]}" 2>&1
    elif [ "${wifi[1]}" != "unavailable" ];then
        nmcli device wifi hotspot 1>/dev/null 2>&1
    fi
    run_action "continued"
}

# show_password() {
#     if [ "${wifi[1]}" == 'connected' ];then
#         info=$(nmcli device wifi show-password | sed -re '/^$/d') 
#         rofi_option -s message "$info"
#     fi
#     run_action "continued"
# }

wifi_toggle() {
    case "${wifi[1]}" in
        "connected") nmcli radio wifi off;;
        "disconnected") nmcli radio wifi off;;
        "unavailable") nmcli radio wifi on;;
    esac
    run_action "continued"
}

eth_toggle() {
    case "${eth[1]}" in
        "connected") nmcli device disconnect "${eth[0]}";;
        "disconnected") nmcli device connect "${eth[0]}";;
    esac
    run_action "continued"
}

rofi_msg() {
    msg="$@"
    rofi -theme "$ROFI_THEMEDIR/message.rasi" -e "$msg"
}

rofi_menu() {
    IFS="$SEPARATION"
    sel=$(echo -ne "${actions[*]}" \
        | rofi -theme "$ROFI_THEMEDIR/list.rasi" -sep "$SEPARATION" \
        -dmenu -a "$actrow" -u "$urgrow")
    run_action "$sel"
}

run_action() {
    option=$1
    case "$option" in
        "wifi list") wifi_show_list;;
        "hotspot") hotspot_toggle;;
        "scan") wifi_rescan;;
        "wifi toggle") wifi_toggle;;  
        "eth toggle") eth_toggle;;
        "status") network_status;;
        "connected") connected_list;;
        "saved connection") saved_connection_list;;
        "continued") main;;
        "quit") exit 0;;
        *) exit 0;;
    esac
}

main() {
    initialization 
    rofi_menu
}
main "$@"
# tst "$@"
