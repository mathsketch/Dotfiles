#!/usr/bin/bash
if [ "$(systemctl is-active sshd.service)" = "active" ];then
    systemctl stop sshd.service
else
    systemctl start sshd.service
fi
