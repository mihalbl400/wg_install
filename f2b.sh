#!/bin/bash

apt update
apt install git curl wget fail2ban -y
systemctl enable fail2ban
echo "[sshd]
backend=systemd
enabled   = true
maxretry  = 3
findtime  = 1h
bantime   = 365d
ignoreip  = 127.0.0.1/8
" >> /etc/fail2ban/jail.local
systemctl start fail2ban
fail2ban-client status sshd
