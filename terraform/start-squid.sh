#!/bin/bash

export SQUID_CACHE_DIR=/squid3/logs
export SQUID_CONF_DIR=/squid3/conf
export SQUID_USER=proxy

if [[ ! -d $SQUID_CACHE_DIR/00 ]]; then
  echo "Initializing cache..."
  sudo $(which squid) -N -f $SQUID_CONF_DIR/squid.conf -z
fi
echo "Starting squid..."
sudo $(which squid) -f $SQUID_CONF_DIR/squid.conf -NYCd 1
