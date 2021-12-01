#!/usr/bin/bash

progressBar() {
    let _progress=(${1}*100/${2}*100)/100
    let _done=(${_progress}*4)/10
    let _left=40-$_done

    _fill=$(printf "%${_done}s")
    _empty=$(printf "%${_left}s")

    printf "\rProgress : [${_fill// /=}${_empty// /-}] ${_progress}%%"

}

status=$(progress -wqc cp)
while [ -n "$status" ];do
    percent=$(echo "$status" | sed -nE 'n;s/[^[:print:]]//p' | \
        sed -nE 's/^([0-9]*).[0-9]*%.*/\1/p')
    progressBar $percent 100
    status=$(progress -wqc cp)
done
