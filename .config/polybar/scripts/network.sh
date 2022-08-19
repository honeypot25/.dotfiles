#!/usr/bin/env bash

interval=$1

while true; do
  # get NICs with state
  read -d '\n' -r ETH_NIC _ WIFI_NIC wifi_state < <(ip link | rg "^\d: ([ew]\w+):.+ state (UP|DOWN)" -or '$1 $2')

  # choose NIC
  if [ "$wifi_state" = "UP" ]; then
    NIC="$WIFI_NIC"
    icon=
  else
    NIC="$ETH_NIC"
    icon=
  fi

  # get current downspeed
  old_bytes="$(cat /sys/class/net/"$NIC"/statistics/rx_bytes)"
  sleep "$interval"
  new_bytes="$(cat /sys/class/net/"$NIC"/statistics/rx_bytes)"
  bytes=$((((new_bytes - old_bytes)) / interval))

  # set speed
  if [ $bytes -eq 0 ] || [ $bytes -lt 1000 ]; then
    downspeed="0 KB/s"
  elif [ $bytes -lt 1000000 ]; then
    downspeed="$(echo "$bytes / 1000" | bc -l | LC_NUMERIC=en_US.UTF-8 xargs printf "%d KB/s")"
  else
    downspeed="$(echo "$bytes / 1000000" | bc -l | LC_NUMERIC=en_US.UTF-8 xargs printf "%.1f MB/s")"
  fi

  # polybar label
  echo "$icon $downspeed"
done
