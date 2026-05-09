#!/bin/sh
if [ -s /etc/resolv.conf.vpn-backup ]; then
  cp -f /etc/resolv.conf.vpn-backup /etc/resolv.conf
else
  echo 'nameserver 127.0.0.11' > /etc/resolv.conf
fi
