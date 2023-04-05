#!/usr/bin/env bash

# coding
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias sv="sudo nvim"
alias py="python3"
alias shellcheck="shellcheck -e 1090,1091,2034,2139,2154"
alias gcc="gcc -Wall"
alias smake="make -s"

# utility
alias trash="rm -rfv $HOME/.local/share/Trash/*"
alias prename="perl-rename"
alias rshrink="shopt -s globstar; rename -v 's/ /_/g' ./**; shopt -u globstar" # recursive replace spaces with _
alias rgi="rg -i"
alias nf="neofetch --config $HOME/.config/neofetch/nf.conf"
alias nfa="neofetch --config $HOME/.config/neofetch/nfa.conf"
alias ts="sudo timeshift-gtk"
#alias ff="fastfetch --load-config $HOME/.config/fastfetch/ff.conf | lolcat -t"
#alias ffa="fastfetch --load-config $HOME/.config/fastfetch/ffa.conf | lolcat -t"
#alias zathura='zathura -e $(tabbed -c) & disown'

# replace "ls" with "exa"
alias ls="exa --icons --grid --group --group-directories-first"
alias la="ls -a"
alias ll="ls -l"
alias llh="ll --header"
alias lal="ls -al"
alias lalh="lal --header"
alias lt="ls -T"
alias l.='ls -a | egrep "^\."'

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
alias up="SKIP_AUTOSNAP= paru" # update standard & AUR pkgs (paru -Syu)
# misc
alias unlock="sudo rm /var/lib/pacman/db.lck"

# get fastest mirrors
alias mirrors="sudo reflector \
  --country it \
  --fastest 3 \
  --latest 3 \
  --protocol http,https \
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
alias aa="cd $HOME/projects/auto-arch/"
alias gitp="git s && git a . && git cam 'autocommit' && git psom"
# dotfiles bare git repo
alias dots='/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias dotsp="dots s && dots cam 'autocommit' && dots psom"
