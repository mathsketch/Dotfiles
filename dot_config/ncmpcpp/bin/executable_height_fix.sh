#!/usr/bin/bash
arg_file="$HOME/.config/ncmpcpp/ncmpcpp-ueberzug/arg"
if [ "$(cat "$arg_file" | cut -d ' ' -f1)" != 0 ];then
    echo "0 2" > "$arg_file"
else
    echo "3 0" > "$arg_file"
fi

