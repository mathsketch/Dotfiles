#!/usr/bin/bash
SEPARATION="\r"
CACHEFILE="$HOME/.cache/rofi/nmcli_rofi"
[ "$ROFI_RETV" == '0' ] && echo -ne "\0delim\x1f$SEPARATION\n"

rofi_option() {
    option=$1;shift
    case "$option" in
        -e) 
          if [ "$#" -gt '1' ];then 
              printf "${1}\0${2}";shift 2
          else
              printf "$1";shift
          fi
        ;;
        -s) printf "\0${1}"; shift
    esac
    for arg in "$@";do
        printf "\x1f$arg"
    done
    printf "$SEPARATION"
}

fw() {
  local STR=$1; shift
  local WIDTH=$1; shift
  local BYTEWIDTH=$( echo -n "$STR" | wc -c )
  local CHARWIDTH=$( echo -n "$STR" | wc -m )
  echo $(( $WIDTH + ($BYTEWIDTH - $CHARWIDTH) ))
}

initial_menu() {
    get_device_info
    rofi_option -s message ''
    line=0
    if [ "$(iw wlo1 info | grep -i type | cut -d ' ' -f 2)" == 'AP' ];then
        rofi_option -e "hotspot toggle"; rofi_option -s active 0
        rofi_option -e "show password"
        ((line+=2))
    elif [ "${wifi[1]}" == "connected" ];then
        rofi_option -e "wifi list" 
        rofi_option -e "hotspot toggle"
        rofi_option -e "show password"
        ((line+=3))
    elif [ "${wifi[1]}" == "disconnected" ];then
        rofi_option -e "wifi list" 
        rofi_option -e "hotspot toggle"
        ((line+=2))
    fi
    rofi_option -e "wifi toggle"
    [ "${wifi[1]}" == "connected" ] && rofi_option -s active "$line"
    [ "${wifi[1]}" == "unavailable" ] && rofi_option -s urgent "$line" 
    ((line+=1))
    rofi_option -e "eth toggle";
    [ "${eth[1]}" == "connected" ] && rofi_option -s active "$line" 
    [ "${eth[1]}" == "unavailable" ] && rofi_option -s urgent "$line"
    rofi_option -e "status"
    if [ "$(nmcli connection show -a | sed -ne '$=')" -gt 1 ];then
        rofi_option -e "connected list"
    # else
    #     connected_list
    fi
    if [ "$(nmcli connection show  | sed -ne '$=')" -gt 1 ];then
        rofi_option -e "saved connection list"
    # else
    #     saved_connection_list
    fi
    rofi_option -e "quit"
}

wifi_show_list() {
    printf "\0message\x1f%-4s %-15s %s" "BARS" "SECURITY" "SSID"
    rofi_option -e ""
    nmcli -g SSID,BARS,SECURITY device wifi list | while read -r wifi;do
        wifi_ssid=$(echo "$wifi" | sed -re 's/^(.*):.*:.*$/\1/')
        wifi_bars=$(echo "$wifi" | sed -re 's/^.*:(.*):.*$/\1/')
        wifi_security=$(echo "$wifi" | sed -re 's/^.*:.*:(.*)$/\1/')
        [ -z "$wifi_ssid" ] && continue
        printf "%-4s <span font_desc='NotoSans 12'>%-20s</span> %+10s"\
            "$wifi_bars" "$wifi_ssid" "$wifi_security"
        rofi_option -e "" info "wifi_connect $wifi_ssid;$wifi_security"
    done
    rofi_option -e "rescan"
    rofi_option -e "continued"
}

wifi_rescan() {
    if [ "${wifi[1]}" != "unavailable" ];then
        nmcli device wifi rescan
    fi
    wifi_show_list
}

wifi_connect() {
    rofi_option -s message ""
    id=$(echo "$@" | cut -d ';' -f 1)
    sec=$(echo "$@" | cut -d ';' -f 2) 
    if [ -z "$sec" ];then
        rofi_option -s message "$(nmcli device wifi connect "$id")"
    else
        echo -ne "connect_wifi\n$id\n" > "$CACHEFILE"
        exit 0
    fi
    rofi_option -e "continued"
}

connection_down() {
    name="$@"
    rofi_option -s message "$(nmcli connection down "$name")"
    rofi_option -e "continued"
}

connection_up() {
    name="$@"
    rofi_option -s message "$(nmcli connection up "$name")"
    rofi_option -e "continued"
}

saved_connection_list() {
    connection=$(nmcli -g NAME,TYPE,DEVICE connection show)
    printf "\0message\x1f%-17s %-20s %-10s" "NAME" "TYPE" "DEVICE"
    rofi_option -e ""
    echo "$connection" | while read -r line;do
        connection_name=$(echo "$line" | sed -re 's/^(.*):.*:.*$/\1/')
        connection_type=$(echo "$line" | sed -re 's/^.*:(.*):.*$/\1/')
        connection_device=$(echo "$line" | sed -re 's/^.*:.*:(.*)$/\1/')
        printf "%-$(fw "$connection_name" 20)s %-20s %-10s" \
            "$connection_name" "$connection_type" "$connection_device"
        rofi_option -e "" info "connection_up $connection_name"
    done
    rofi_option -e "continued"
}

connected_list() {
    connection=$(nmcli -g NAME,TYPE,DEVICE connection show -a)
    printf "\0message\x1f%-17s %-20s %-10s" "NAME" "TYPE" "DEVICE"
    rofi_option -e ""
    echo "$connection" | while read -r line;do
        connection_name=$(echo "$line" | sed -re 's/^(.*):.*:.*$/\1/')
        connection_type=$(echo "$line" | sed -re 's/^.*:(.*):.*$/\1/')
        connection_device=$(echo "$line" | sed -re 's/^.*:.*:(.*)$/\1/')
        printf "%-20s %-20s %-10s" \
            "$connection_name" "$connection_type" "$connection_device"
        rofi_option -e "" info "connection_down $connection_name"
    done
    rofi_option -e "continued"
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
        rofi_option -s message "$(nmcli device disconnect "${wifi[0]}" 2>&1)"
    elif [ "${wifi[1]}" != "unavailable" ];then
        rofi_option -s message "$(nmcli device wifi hotspot 1>/dev/null 2>&1)"
    fi
    selection_action "continued"
}

show_password() {
    if [ "${wifi[1]}" == 'connected' ];then
        info=$(nmcli device wifi show-password | sed -re '/^$/d') 
        rofi_option -s message "$info"
    fi
    rofi_option -e "continued"
}

wifi_toggle() {
    case "${wifi[1]}" in
        "connected") nmcli radio wifi off;;
        "disconnected") nmcli radio wifi off;;
        "unavailable") nmcli radio wifi on;;
    esac
    selection_action "continued"
}

eth_toggle() {
    case "${eth[1]}" in
        "connected") nmcli device disconnect "${eth[0]}";;
        "disconnected") nmcli device connect "${eth[0]}";;
    esac
    selection_action "continued"
}

network_status() {
    echo -ne "view_status\n" > "$CACHEFILE"
}

selection_action() {
    get_device_info
    option=$1
    case "$option" in
        "wifi list") wifi_show_list;;
        "hotspot toggle") hotspot_toggle;;
        "show password") show_password;;
        "rescan") wifi_rescan;;
        "wifi toggle") wifi_toggle;;  
        "eth toggle") eth_toggle;;
        "status") network_status;;
        "connected list") connected_list;;
        "saved connection list") saved_connection_list;;
        "continued") initial_menu;;
        "quit") exit 0;;
        *) 
          action=$(echo "$ROFI_INFO" | cut -d ' ' -f 1)
          info=$(echo "$ROFI_INFO" | sed -re 's/^[a-z_]* //')
          case "$action" in
            "wifi_connect") wifi_connect "$info";;
            "connection_up") connection_up "$info";;
            "connection_down") connection_down "$info";;
          esac
        ;;
    esac
}

main() {
    rofi_option -s markup-rows true
    rofi_option -s prompt 爵
    [ -z "$@" ] && initial_menu || selection_action "$@"
}
main "$@"
