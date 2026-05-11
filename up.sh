#!/bin/sh
env | grep '^foreign_option_' | sed 's/^[^=]*=//' \
  | awk '/^dhcp-option DNS/ {print "nameserver " $3}' > /etc/resolv.conf
