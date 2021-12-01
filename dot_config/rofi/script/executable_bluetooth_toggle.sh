#!/usr/bin/bash
bluetooth_toggle() {
    if bluetoothctl show | grep -q "Powered: no"; then
        bluetoothctl power on > /dev/null
    else
        devices_paired=$(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
        echo "$devices_paired" | while read -r line; do
            bluetoothctl disconnect "$line" > /dev/null
        done
        bluetoothctl power off > /dev/null
    fi
}
bluetooth_toggle
