#!/bin/sh
cp /etc/resolv.conf /etc/resolv.conf.vpn-backup 2>/dev/null || true
env | grep '^foreign_option_' | sed 's/^[^=]*=//' \
  | awk '/^dhcp-option DNS/ {print "nameserver " $3}' > /etc/resolv.conf
