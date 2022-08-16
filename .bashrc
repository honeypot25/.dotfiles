#!/usr/bin/env bash

## EXPORTS
export TERM=xterm-256color
# export EDITOR=nvim
# export VISUAL=
# export MANPAGER="nvim -c 'set ft=man' -"
# export MANPAGER=less
export PATH="$PATH:$HOME/.local/bin:$HOME/.bin:$HOME/apps"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

## PROMPT
green=$(tput setaf 2)
red=$(tput setaf 1)
rst=$(tput sgr0)
PS1="[\[$green\]\u\[$rst\]   \[$red\]\w\[$rst\]]   "
unset green red rst

## HISTORY
HISTCONTROL=ignoredups:erasedups # ignoreboth
HISTSIZE=1000
HISTFILE=~/.bash_history

## SHOPT
shopt -s autocd       # change to named directory
shopt -s cdspell      # autocorrects cd misspellings
shopt -s checkwinsize # checks term size when bash regains control
shopt -s cmdhist      # save multi-line commands in history as single line
shopt -s dotglob
# shopt -s extglob # ? * + @ !
shopt -s expand_aliases # expand aliases
shopt -s histappend     # do not overwrite history

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
ex() {
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

### ALIASES
# coding
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias py="python3"
alias shellcheck="shellcheck -e 1090,1091,2034,2139,2154"

# utility
alias trash="rm -rfv $HOME/.local/share/Trash/*"
alias prename="perl-rename"
alias rshrink="shopt -s globstar; rename -v 's/ /_/g' ./**; shopt -u globstar" # recursive replace spaces with _
alias ff="fastfetch --load-config $HOME/.config/fastfetch/ff.conf | lolcat -t"
alias ffa="fastfetch --load-config $HOME/.config/fastfetch/ffa.conf | lolcat -t"

# changing "ls" to "exa"
alias ls="exa --color=always --group-directories-first"
alias la="exa -a --color=always --group-directories-first"
alias ll="exa -l --color=always --group-directories-first"
alias lal="exa -al --color=always --group-directories-first"
alias lt="exa -T --color=always --group-directories-first"
alias l.='exa -a | egrep "^\."'

# pacman & paru
# install
alias pac="sudo pacman -Sy"
alias par="paru -Sy"
# query updates
alias pacq="sudo pacman -Sy && sudo pacman -Qu"
alias parq="paru -Sy && paru -Qua"
# autoupdate
alias pacup="sudo pacman -Syu" # update standard pkgs
alias parup="paru -Sua"        # update AUR pkgs
alias up="paru"                # update standard & AUR pkgs (paru -Syu)
# misc
alias unlock="sudo rm /var/lib/pacman/db.lck"

# get fastest mirrors
alias mirrors="sudo reflector \
  --country it \
  --fastest 3 \
  --latest 3 \
  --protocol https \
  --completion-percent 100 \
  --sort rate \
  --threads 4 \
  --save /etc/pacman.d/mirrorlist"

# colorize grep output
alias grep="grep --color=auto"

# confirm before overwriting
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# misc flags
alias echo="echo -e" # enable \ escapes
alias du="du -h"
alias df="df -h"
alias free="free -hw --si"

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"
alias psmem="ps auxf | sort -nr -k 4"
alias pscpu="ps auxf | sort -nr -k 3"

# get error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# youtube-dl
alias yt="youtube-dl"
alias yta-aac="youtube-dl --extract-audio --audio-format aac"
alias yta-best="youtube-dl --extract-audio --audio-format best"
alias yta-flac="youtube-dl --extract-audio --audio-format flac"
alias yta-m4a="youtube-dl --extract-audio --audio-format m4a"
alias yta-mp3="youtube-dl --extract-audio --audio-format mp3"
alias yta-opus="youtube-dl --extract-audio --audio-format opus"
alias yta-vorbis="youtube-dl --extract-audio --audio-format vorbis"
alias yta-wav="youtube-dl --extract-audio --audio-format wav"
alias ytv-best="youtube-dl -f bestvideo+bestaudio"

# generic git
alias gitp="git s && git a . && git cam 'autocommit' && git psom"
# dotfiles bare git repo
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias dotsp="dots s && dots cam 'autocommit' && dots psom"

### SCRIPTS
# SSH keychain
eval "$(keychain --confhost --eval --noask --nogui --quiet "$HOME/.ssh/{id_github}")"
