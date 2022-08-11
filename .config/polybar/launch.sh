#!/usr/bin/env bash

killall -q polybar && sleep 1

echo -e "\n+++ +++ +++ $(date +"%a %d %b | %X") +++ +++ +++\n" | tee -a /tmp/polybar.log

### env variables
#DEFAULT_NIC=$(ip route | grep "^default" | head -n1 | cut -d' ' -f5)
#WIFI_NIC=$(ip link | rg "^\d: (w\w+)" -or '$1')

# DEFAULT_MON & MAIN_MON
read -d'\n' -r DEFAULT_MON MAIN_MON < <(polybar -m | head -n2 | cut -d':' -f1) # ext*. fallback: main
# read -d'\n' -r MAIN_MON EXT_MON HDMI_MON VIRT_MON < <(xrandr --query | tail -n+2 | rg "^(\w+) " -or '$1')

# ADAPTER & BATTERY
read -d' ' -r ADAPTER BATTERY < <(ls /sys/class/power_supply/)

function network() {
  read -r ETH_NIC eth_up WIFI_NIC wifi_up < <(ip link | rg "^\d: ([ew]\w+):.+ state (\w+)" -or '$1 $2')
  if [ "$eth_up" = "UP" ] && [ "$wifi_up" = "UP" ]; then
    ACTIVE_NIC="$ETH_NIC"
    #LABEL_CONNECTED=" E|W %{F#6C77BB}%{F-} %downspeed%"
  elif [ "$eth_up" = "UP" ]; then
    ACTIVE_NIC="$ETH_NIC"
    #LABEL_CONNECTED=" E %{F#6C77BB}%{F-} %downspeed%"
  elif [ "$wifi_up" = "UP" ]; then
    ACTIVE_NIC="$WIFI_NIC"
    #LABEL_CONNECTED=" W %{F#6C77BB}%{F-} %downspeed%"
  fi

}
network

### env variables exports
export DEFAULT_MON MAIN_MON
export ADAPTER BATTERY
export ACTIVE_NIC ETH_NIC #LABEL_CONNECTED

# start (with automatic reloads after config.ini changes)
polybar --log=error --reload main 2>&1 | tee -a /tmp/polybar.log &
disown
