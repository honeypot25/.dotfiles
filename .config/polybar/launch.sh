#!/usr/bin/env bash

killall polybar

### env variables

# ADAPTER, BATTERY
read -d' ' -r ADAPTER BATTERY < <(ls /sys/class/power_supply/)

# DEFAULT_MON, INT_MON
read -d'\n' -r DEFAULT_MON INT_MON < <(polybar -m | head -n2 | cut -d':' -f1) # ext*. fallback: main

function network() {
  read -d '\n' -r ETH_NIC eth_up WIFI_NIC wifi_up < <(ip link | rg "^\d: ([ew]\w+):.+ state (UP|DOWN)" -or '$1 $2')
  [ "$wifi_up" = "UP" ] && ACTIVE_NIC="$WIFI_NIC" || ACTIVE_NIC="$ETH_NIC"
}
network

export ADAPTER BATTERY
export DEFAULT_MON INT_MON
export ACTIVE_NIC ETH_NIC WIFI_NIC

# start with automatic reloads after config.ini changes
echo -e "+++ +++ +++ $(date +"%a %d %b | %X") +++ +++ +++\n" >/tmp/polybar.log
polybar --log=error --reload main &>>/tmp/polybar.log &
