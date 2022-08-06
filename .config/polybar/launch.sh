#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

echo "---" | tee -a /tmp/polybar.log
# override monitor name for XRandR 1.5+ randomized monitor names
MONITOR=$(polybar -m|tail -1|sed -e 's/:.*$//g') polybar main 2>&1 | tee -a /tmp/polybar.log & disown
