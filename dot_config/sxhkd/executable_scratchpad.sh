#!/usr/bin/bash
id=$(xdotool search --class nvim_floating)
if [[ -z $id ]];then 
    st -c nvim_floating -e nvim $HOME/file/VimWiki/index.md &
else
    [[ $(bspc query -n $id.local -N) || $(bspc query -n $id.hidden -N) ]] && bspc node $id --flag hidden
    bspc node $id -d $(bspc query -D -d) -f
fi
