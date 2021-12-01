#!/usr/bin/bash

set -e
[[ -n "$DISPLAY" ]] || { /usr/bin/lf "$@";exit 0; }

export CONFIG_BIN="$HOME/.config/lf/bin"
export LF_CACHE="$HOME/.cache/lf"
export FIFO_UEBERZUG="/tmp/lf-ueberzug-$$"

cleanup() {
    exec 3>&-
    rm -f "$FIFO_UEBERZUG"
}

if ! [[ -d "$LF_CACHE" ]];then
    mkdir -p "$LF_CACHE"
fi
xhost + >/dev/null
mkfifo "$FIFO_UEBERZUG" || exit 1
ueberzug layer --parser json --loader synchronous < "$FIFO_UEBERZUG" 2>/dev/null &
exec 3>"$FIFO_UEBERZUG"

trap cleanup EXIT

source "$CONFIG_BIN"/iconset.sh
LC_ALL=en_US.UTF-8 /usr/bin/lf "$@" 3>&-
"$CONFIG_BIN"/clean.sh
