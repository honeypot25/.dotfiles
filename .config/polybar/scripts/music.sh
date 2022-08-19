#!/usr/bin/env bash

if ! playerctl --player=spotify,%any status -s; then
  # polybar-msg action "#music-hooks.hook.-0" &>/dev/null
  echo "Off"
  exit 1
fi

status=$(playerctl status 2>/dev/null)
case $status in
Playing)
  # get_song="playerctl metadata -f '{{ title }} • {{ duration(position) }}/{{ duration(mpris:length) }}'"
  get_song="playerctl metadata -f '{{ title }}'"
  # print format with scrolling
  eval "$get_song" |
    zscroll \
      --delay 0.3 \
      --length 35 \
      --scroll-padding "  ♪  " \
      --update-check true "$get_song" &
  wait
  ;;
Paused | Stopped)
  echo "$status"
  ;;
*)
  echo "Off"
  ;;
esac
