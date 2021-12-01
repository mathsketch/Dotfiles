#!/usr/bin/bash
DIR="$HOME/.config/rofi"
SCRIPTDIR="$DIR/script"
ROFI_THEMEDIR="$DIR/themes"
MODE="$DIR/bin/setting_mode.sh"

rofi -theme "${ROFI_THEMEDIR}/setting.rasi" -modi "setting:$MODE script,configuration:$MODE config" -show setting -selected-row 0 
