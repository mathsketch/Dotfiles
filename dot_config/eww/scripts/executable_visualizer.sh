#!/usr/bin/bash
PIDFILE="$HOME/.cache/eww/$(basename $0).pid"
CAVACONFIG="$HOME/.config/eww/cavarc"
bar_ascii=('▁' '▂' '▃' '▄' '▅' '▆' '▇' '█')

if [ -f "$PIDFILE" ];then
    pid=$(cat "$PIDFILE")
    kill -TERM "$pid";sleep 1
    [ -f "$PIDFILE" ] && exit 1 || echo $$ > "$PIDFILE"
else
    echo $$ > "$PIDFILE"
fi

cleanup() {
    rm -f "$PIDFILE"
    pkill -P $$
}

display() {
    trap cleanup SIGINT SIGTERM EXIT

    cava -p "$CAVACONFIG" 2>/dev/null | while read -r line;do
        content=($(echo $line | sed -re 's/;/ /g'))
        if [ "$((${content[@]/%/+}0))" -eq 0 ];then
            count=$(($count+1))
        else
            count=0
        fi

        unset vis_bar
        for i in "${content[@]}";do
            if [ "$count" -gt 300 ];then
                vis_bar=" "
            else
                vis_bar+="${bar_ascii[i]}"
            fi
        done

        echo "$vis_bar"
    done &
    wait
}

display
cleanup
