#!/usr/bin/bash
pid=$(pgrep -x screenkey)
if [ -z "$pid" ];then
    screenkey --no-systray
else
    kill "$pid"
fi
