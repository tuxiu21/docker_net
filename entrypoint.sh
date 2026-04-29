#!/bin/sh
set -e

printf '%s\n%s\n' "${VPN_USER:-}" "${VPN_PASS:-}" > /tmp/auth.txt
chmod 600 /tmp/auth.txt

sed 's|^auth-user-pass.*|auth-user-pass /tmp/auth.txt|' /vpn/vpn.conf.orig > /tmp/vpn.conf

exec openvpn --config /tmp/vpn.conf \
  --script-security 2 --up /up.sh \
  --data-ciphers 'AES-256-GCM:AES-128-GCM:CHACHA20-POLY1305:AES-128-CBC' \
  --data-ciphers-fallback AES-128-CBC
