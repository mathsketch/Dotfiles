#!/usr/bin/bash
PATH_BATTERY="/sys/class/power_supply/BAT0"
PATH_AC="/sys/class/power_supply/AC0"
index=0

while [[ -d "$PATH_BATTERY" ]];do
  battery_status=$(cat "$PATH_BATTERY/status")
  battery_capacity=$(cat "$PATH_BATTERY/capacity")
  ac_online=$(cat "$PATH_AC/online")
  if [[ "$battery_status" = 'charging' ]];then
    if [[ $index -lt 5 ]];then
      ((index++))
    else
      index=1
    fi
  else
    if [[ $battery_capacity -gt 95 ]];then
      index=$((10 - $ac_online*5))
    elif [[ $battery_capacity -gt 70 ]];then
      index=$((9 - $ac_online*5))
    elif [[ $battery_capacity -gt 40 ]];then
      index=$((8 - $ac_online*5))
    elif [[ $battery_capacity -gt 10 ]];then
      index=$((7 - $ac_online*5))
    else
      index=$((6 - $ac_online*5))
    fi
  fi

  case $index in 
    # 1) icon='%{F#0DA91F}%{T4}%{T-}%{F-}';;
    # 2) icon='%{F#0DA91F}%{T4}%{T-}%{F-}';;
    # 3) icon='%{F#0DA91F}%{T4}%{T-}%{F-}';;
    # 4) icon='%{F#0DA91F}%{T4}%{T-}%{F-}';;
    # 5) icon='%{F#0DA91F}%{T4}%{T-}%{F-}';;
    # 6) icon='%{F#DB3432}%{T4}%{T-}%{F-}';;
    # 7) icon='%{F#EE9904}%{T4}%{T-}%{F-}';;
    # 8) icon='%{F#D6D504}%{T4}%{T-}%{F-}';;
    # 9) icon='%{F#74C705}%{T4}%{T-}%{F-}';;
    # 10) icon='%{F#0DA91F}%{T4}%{T-}%{F-}';;
    1) icon='%{T4}%{T-}';;
    2) icon='%{T4}%{T-}';;
    3) icon='%{T4}%{T-}';;
    4) icon='%{T4}%{T-}';;
    5) icon='%{T4}%{T-}';;
    6) icon='%{T4}%{T-}';;
    7) icon='%{T4}%{T-}';;
    8) icon='%{T4}%{T-}';;
    9) icon='%{T4}%{T-}';;
    10) icon='%{T4}%{T-}';;
  esac

  echo "${icon} "
  sleep 1
done
