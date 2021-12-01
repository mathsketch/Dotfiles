#!/usr/bin/bash

cavaConfig="$HOME/.config/polybar/cavarc"
color1='#C59851'
color2='#CC9245'
color3='#D28D3A'
color4='#D9872E'
color5='#DF8223'
color6='#E67C17'
color7='#EC770C'
color8='#F37100'
# color1='#C59851'
# color2='#C59851'
# color3='#C59851'
# color4='#C59851'
# color5='#C59851'
# color6='#C59851'
# color7='#C59851'
# color8='#C59851'

display() {
    cava -p $cavaConfig | while read line;do
        printf " %s" "%{O2}"
        for i in $(echo $line | awk -F ';' '{print $1,$2,$3,$4,$6,$7,$8}');do
            if [[ i -le 125 ]];then
                printf '%s▁%s' "%{O-2}%{F$color1}" "${F}"
            elif [[ i -le 250 ]];then
                printf '%s▂%s' "%{O-2}%{F$color2}" "${F}"
            elif [[ i -le 375 ]];then
                printf '%s▃%s' "%{O-2}%{F$color3}" "${F}"
            elif [[ i -le 500 ]];then
                printf '%s▄%s' "%{O-2}%{F$color4}" "${F}"
            elif [[ i -le 675 ]];then
                printf '%s▅%s' "%{O-2}%{F$color5}" "${F}"
            elif [[ i -le 750 ]];then
                printf '%s▆%s' "%{O-2}%{F$color6}" "${F}"
            elif [[ i -le 875 ]];then
                printf '%s▇%s' "%{O-2}%{F$color7}" "${F}"
            else
                printf '%s█%s' "%{O-2}%{F$color8}" "${F}"
            fi
        done
        printf "%s \n" "%{O-2}"
    done
}

display
