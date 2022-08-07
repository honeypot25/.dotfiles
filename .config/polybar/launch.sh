#!/usr/bin/env bash

killall -q polybar && sleep 1

echo "---" | tee -a /tmp/polybar.log

### env variables
#DEFAULT_NIC=$(ip route | grep "^default" | head -n1 | cut -d' ' -f5)
#WIFI_NIC=$(ip link | rg "^\d: (w\w+)" -or '$1')
MONITOR=$(polybar -m|tail -1|sed -e 's/:.*$//g') # fallback eDP1

function network() {
  # fallback: ETH_NIC
  read -r ETH_NIC eth_UP WIFI_NIC wifi_UP < <(ip link | rg "^\d: ([ew]\w+): .+ state (\w+)" -or '$1 $2')
  LABEL_CONNECTED="%{F#6C77BB}%{F-} %upspeed% %{F#6C77BB}%{F-} %downspeed%"
  if [ "ETH_NIC" = "UP" ] && [ "WIFI_NIC" = "UP" ]; then
    FCP="📶 / "
    LABEL_CONNECTED=": ETH / WiFi"
  elif [ "$eth_UP" = "UP" ]; then
    ACTIVE_NIC="$ETH_NIC"
    FCP="📶"
    FDP="🚫📶"
  elif [ "$wifi_UP" = "UP" ]; then
    ACTIVE_NIC="$WIFI_NIC"
    FCP=""
    FDP=""
  else
    FDP="✈️"
  fi
};

# start
polybar main 2>&1 | tee -a /tmp/polybar.log & disown

