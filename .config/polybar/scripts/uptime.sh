#!/usr/bin/env bash

# Xd Yh Zm
uptime -p | cut -d' ' -f2- | rg "(\d+) (.)\w+,?" -r '$1$2' | sed 's/ //g'

