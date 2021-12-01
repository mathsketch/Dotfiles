#!/usr/bin/bash
DIR="$HOME/.config/rofi"
SCRIPTDIR="$DIR/script"
SETLIST="$DIR/setlist"
CONFLIST="$DIR/conflist"
ROFI_THEMEDIR="$DIR/themes"

red="#cc241d"
green="#689d6a"
sep=' ┊ '

if [ "$(systemctl --user is-active clash.service)" = "active" ];then
    clash_status="<span foreground='$green'> clash</span>"
else
    clash_status="<span foreground='$red'> clash</span>"
fi

if [ "$(systemctl is-active sshd.service)" = "active" ];then
    sshd_status="<span foreground='$green'>sshd</span>"
else
    sshd_status="<span foreground='$red'>sshd</span>"
fi

msg="<b>${clash_status}${sep}${sshd_status}</b>"


run_script() {
    tar=$ROFI_INFO
    if [ -f "${tar}" ];then
        path="${tar}"
    elif [ -f "${SCRIPTDIR}/${tar}" ];then
        path="${SCRIPTDIR}/${tar}"
    fi

    coproc ( bash "$path" >/dev/null 2>&1 )
}

open_file() {
    path=$ROFI_INFO
    coproc ( st -e nvim "$path" >/dev/null 2>&1 )
}

run() {
    case "$1" in
        script) run_script;;
        config) open_file;;
    esac
}

message() {
    case "$1" in
        script) echo -ne "\0message\x1f${msg}\n";;
    esac
}

rofi_entry() {
    case "$1" in
        script) list=$SETLIST;;
        config) list=$CONFLIST;;
    esac

    cat "$list" | while read -r line;do
        descr=$(echo "$line" | cut -d ';' -f 1) 
        file=$(echo "$line" | cut -d ';' -f 2) 
        echo -ne "${descr}\0info\x1f${file}\n"
    done
}

main() {
    mode="$1";shift
    if [ -z "$@" ];then
        rofi_entry "$mode"
    else
        run "$mode"
    fi
    message "$mode"
}
main "$@"
