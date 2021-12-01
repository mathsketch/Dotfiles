#!/usr/bin/bash
CAVACONFIG="$HOME/.config/eww/cavarc"
bar_ascii=('▁' '▂' '▃' '▄' '▅' '▆' '▇' '█')

display() {
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
    done
}

display
