#!/bin/sh
# Force IPv4 resolution for the database hostname in DATABASE_URL.
# The Prisma schema engine (Rust binary) cannot connect to Neon via IPv6.
# This script resolves the hostname to IPv4 and pins it in /etc/hosts.
HOST=$(echo "$DATABASE_URL" | sed -n 's|.*@\([^:/]*\).*|\1|p')
if [ -n "$HOST" ]; then
  IP=$(getent ahostsv4 "$HOST" | head -1 | awk '{print $1}')
  if [ -n "$IP" ]; then
    echo "$IP $HOST" >> /etc/hosts
  fi
fi
