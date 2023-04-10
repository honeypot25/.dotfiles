#!/usr/bin/env bash

### XDG compliance - cleanup
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CACHE_HOME="$HOME"/.cache
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_CONFIG_DIRS=/etc/xdg
export XDG_STATE_HOME="$HOME"/.local/state

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export HISTFILE="$XDG_STATE_HOME"/bash/history
export ICEAUTHORITY="$XDG_CACHE_HOME"/ICEauthority
export INPUTRC="$XDG_CONFIG_HOME"/inputrc
export LESSHISTFILE="-"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/password-store
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
# export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
alias keychain="keychain --dir $XDG_RUNTIME_DIR/keychain"
alias mysql-workbench="mysql-workbench --configdir=$XDG_DATA_HOME/mysql/workbench"
alias wget="wget --hsts-file=$XDG_DATA_HOME/wget-hsts"
alias yarn="yarn --use-yarnrc $XDG_CONFIG_HOME/yarn/config"

### Colors
export TERM=xterm-256color
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
export RED GREEN RESET
export PATH="$PATH:$HOME/.local/bin:$HOME/.bin:$HOME/apps:/usr/share/texmf-dist"

### If not running interactively, don't do anything
[[ $- != *i* ]] && return

### PROMPT
PS1="[\[$GREEN\]\u\[$RESET\]   \[$RED\]\w\[$RESET\]]   "

## HISTORY
HISTCONTROL=ignoredups:erasedups # ignoreboth
HISTSIZE=5000

### SHELL OPTIONS
shopt -s autocd       # change to named directory
shopt -s cdspell      # autocorrects cd misspellings
shopt -s checkwinsize # checks term size when bash regains control
shopt -s cmdhist      # save multi-line commands in history as single line
shopt -s histappend
shopt -s expand_aliases
shopt -s failglob # error upon no match
shopt -s dotglob  # match also dot files (except . and ..)
# shopt -s extglob      # pattern-list ? * + @ ! before (...)

### COMPLETION
bind "set completion-ignore-case on" # ignore upper and lowercase when TAB completion

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi

### ALIASES
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
# alternative aliases
[ -f ~/.bash_aliases.alt ] && source ~/.bash_aliases.alt

### SCRIPTS
# SSH keychain
mkdir -p "$XDG_RUNTIME_DIR/keychain"
eval "$(keychain --confhost --eval --noask --nogui --quiet "$HOME/.ssh/id_{github,ssh}")"

xrdb -load "$XDG_CONFIG_HOME/X11/Xresources"
