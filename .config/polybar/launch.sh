#!/usr/bin/env bash

killall -q polybar && sleep 1

echo "---" | tee -a /tmp/polybar.log

### env variables
#DEFAULT_NIC=$(ip route | grep "^default" | head -n1 | cut -d' ' -f5)
#WIFI_NIC=$(ip link | rg "^\d: (w\w+)" -or '$1')
MONITOR=$(polybar -m|tail -1|sed -e 's/:.*$//g') # fallback eDP1

function network() {
  read -r ETH_NIC eth_up WIFI_NIC wifi_up < <(ip link | rg "^\d: ([ew]\w+):.+ state (\w+)" -or '$1 $2')
  if [ "eth_up" = "UP" ] && [ "wifi_up" = "UP" ]; then
    ACTIVE_NIC="$ETH_NIC"
    LABEL_CONNECTED=" E|W %{F#6C77BB}%{F-} %downspeed%"
  elif [ "$eth_up" = "UP" ]; then
    ACTIVE_NIC="$ETH_NIC"  
    LABEL_CONNECTED=" E %{F#6C77BB}%{F-} %downspeed%"
  elif [ "$wifi_up" = "UP" ]; then
    ACTIVE_NIC="$WIFI_NIC"
    LABEL_CONNECTED=" W %{F#6C77BB}%{F-} %downspeed%"
  fi
  
  export ACTIVE_NIC ETH_NIC LABEL_CONNECTED
}; network

# start
polybar main 2>&1 | tee -a /tmp/polybar.log & disown

