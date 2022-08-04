#!/usr/bin/env bash

## EXPORTS
export TERM=xterm-256color
# export EDITOR=nvim
# export VISUAL=
# export MANPAGER="nvim -c 'set ft=man' -"
# export MANPAGER=less
export PATH="$PATH:$HOME/.bin:$HOME/apps:$HOME/.local/bin"
# export PATH="$PATH:$HOME/.bin:$HOME/apps:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin:/sbin:/usr/sbin/:usr/games"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## PROMPT
green=$(tput setaf 2)
red=$(tput setaf 1)
rst=$(tput sgr0)
PS1="[\[$green\]\u\[$rst\] ➜ \[$red\]\w\[$rst\]] » "
unset green red rst

## HISTORY
HISTCONTROL=ignoredups:erasedups # ignoreboth
HISTSIZE=1000
HISTFILE=~/.bash_history

## SHOPT
shopt -s autocd  # change to named directory
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s dotglob
shopt -s histappend     # do not overwrite history
shopt -s expand_aliases # expand aliases
shopt -s checkwinsize   # checks term size when bash regains control
shopt -s cdspell        # autocorrects cd misspellings

## COMPLETION
bind "set completion-ignore-case on" # ignore upper and lowercase when TAB completion

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
  fi
fi

## ARCHIVE EXTRACTION
extract() {
  if [ -f "$1" ]; then
    arch="$1"
    case $1 in
    *.tar.bz2) tar xjf "$arch" ;;
    *.tar.gz) tar xzf "$arch" ;;
    *.bz2) bunzip2 "$arch" ;;
    *.rar) unrar x "$arch" ;;
    *.gz) gunzip "$arch" ;;
    *.tar) tar xf "$arch" ;;
    *.tbz2) tar xjf "$arch" ;;
    *.tgz) tar xzf "$arch" ;;
    *.zip) unzip "$arch" ;;
    *.Z) uncompress "$arch" ;;
    *.7z) 7z x "$arch" ;;
    *.deb) ar x "$arch" ;;
    *.tar.xz) tar xf "$arch" ;;
    *.tar.zst) unzstd "$arch" ;;
    *) echo "$arch cannot be extracted via ex()" ;;
    esac
  else
    echo "\"$arch\" is not a valid archive file"
  fi
}

## ALIASES
# coding
alias vi="nvim"
alias vim="nvim"
alias py="python3"
alias shellcheck="shellcheck -e 1090,1091,2034,2139,2154"

# utility
alias notrash="rm -rfv $HOME/.local/share/Trash/*"
alias rshrink="shopt -s globstar; rename -v 's/ /_/g' ./**; shopt -u globstar" # recursive replace spaces with _

# changing "ls" to "exa"
alias ls="exa --color=always --group-directories-first"
alias la="exa -a --color=always --group-directories-first"
alias ll="exa -l --color=always --group-directories-first"
alias lal="exa -al --color=always --group-directories-first"
alias lt="exa -T --color=always --group-directories-first"
alias l.='exa -a | egrep "^\."'

# apt, pacman
alias aptup="sudo apt update && sudo apt upgrade -y && sudo apt autoremove --purge -y"
alias pacsyu="sudo pacman -Syu"                 # update only standard pkgs
alias parsua="paru -Sua --noconfirm"            # update only AUR pkgs (paru)
alias parsyu="paru -Syu --noconfirm"            # update standard pkgs and AUR pkgs (paru)
alias unlock="sudo rm /var/lib/pacman/db.lck"   # remove pacman lock
alias cleanup="sudo pacman -Sc && paccache -r -u0 && sudo pacman -Qtdq | sudo pacman -Rns -" # remove orphaned packages

# get fastest mirrors
alias mirror="sudo reflector -c Italy -a24 -n5 -f5 -l5 --verbose"
alias mirrora="sudo reflector -c Italy -a24 -n5 -f5 -l5 --sort age --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector -c Italy -a24 -n5 -f5 -l5 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector -c Italy -a24 -n5 -f5 -l5 --sort score --save /etc/pacman.d/mirrorlist"

# colorize grep output
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

# confirm before overwriting
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# misc flags
alias echo="echo -e" # enable \ escapes
alias du="du -h"
alias df="df -h"
alias free="free --si -hmw"

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem="ps auxf | sort -nr -k 4"
alias pscpu="ps auxf | sort -nr -k 3"

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# youtube-dl
alias yta-aac="youtube-dl --extract-audio --audio-format aac"
alias yta-best="youtube-dl --extract-audio --audio-format best"
alias yta-flac="youtube-dl --extract-audio --audio-format flac"
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a"
alias yta-mp3="youtube-dl --extract-audio --audio-format mp3"
alias yta-opus="youtube-dl --extract-audio --audio-format opus"
alias yta-vorbis="youtube-dl --extract-audio --audio-format vorbis"
alias yta-wav="youtube-dl --extract-audio --audio-format wav"
alias ytv-best="youtube-dl -f bestvideo+bestaudio"

# git
alias ghpush="git s && git a . && git cam 'autocommit' && git psom"

# bare git repo aliasing for dotfiles
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias dotspush="dots s && dots cam 'autocommit' && dots psom"

## SCRIPTS
# eval "$(keychain --eval --quiet --nogui --noask ~/.ssh/id_rsa)" # RSA SSH keychain
