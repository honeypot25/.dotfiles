#!/usr/bin/env bash

set -e

source ~/.packages
log=~/setup.log

testcmd() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "Program \"$1\" is already installed, skipping..."
    return 0
  else
    return 1
  fi
}

prepare() {
  # system update
  sudo pacman -Syu --needed

  echo -e "\nCreating necessary directories\n"
  pushd ~ || return
  # - home dirs
  mkdir -p \
    .src \
    apps \
    coding \
    games \
    misc \
    projects \
    uni \
    vms \	
    Pictures/{screenshots,wallpapers} \
    Videos/screenrec
  # git clone https://gitlab.com/dwt1/wallpapers.git ~/Pictures/wallpapers
  # - XDG compliance / home cleanup
  mkdir -p \
    "$XDG_CACHE_HOME" \
    "$XDG_CONFIG_DIRS" \
    "$XDG_CONFIG_HOME"/{python,mpd/playlists,gtk-2.0,vim,wget,yarn} \
    "$XDG_DATA_DIRS" \
    "$XDG_DATA_HOME"/{cargo,gnupg,pki,mysql/workbench} \
    "$XDG_STATE_HOME"/bash
  popd || return # $PWD

  # install paru
  echo -e "\nInstalling AUR helper (paru)\n"
  testcmd paru && return 1
  pushd ~/.src || return 1
  git clone https://aur.archlinux.org/paru
  pushd paru || return
  makepkg -si --noconfirm
  sudo sed -i 's/^#BottomUp/BottomUp/' /etc/paru.conf
  sudo sed -i 's/^#NewsOnUpgrade/NewsOnUpgrade/' /etc/paru.conf
  popd || return # ~
  popd || return # $PWD
}

install_displaymanager() (
  echo
  while [[ ! "$disp_man" =~ ^lightdm|sddm$ ]]; do
    read -rp "Install your Display Manager (lightdm|sddm): " disp_man
  done
  echo

  install_lightdm() {
    paru -S --needed --noconfirm "${lightdm_pkgs[@]}"
    sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
    # .Xauthority XDG-compliance
    sudo sed -i 's/^#user-authority-in-system-dir=.*/user-authority-in-system-dir=true/' /etc/lightdm/lightdm.conf
    sudo systemctl enable lightdm
  }

  install_sddm() {
    paru -S --needed --noconfirm "${sddm_pkgs[@]}"
    sudo git clone https://github.com/keyitdev/sddm-flower-theme.git /usr/share/sddm/themes/sddm-flower-theme
    sudo cp /usr/share/sddm/themes/sddm-flower-theme/Fonts/* /usr/share/fonts/
    echo "[Theme]
    Current=sddm-flower-theme" | sudo tee /etc/sddm.conf
    sudo systemctl enable sddm
  }

  install_"$disp_man"
)

install_GUI() (
  # choose GUI
  echo
  # kde/xfce/gnome/cinnamon/sway
  while [[ ! "$GUI" =~ ^kde|xfce|i3$ ]]; do
    read -rp "Install your DE/WM (kde/xfce/i3): " GUI
  done
  echo

  # install_kde() {
  #   # packages
  #   paru -S --needed --noconfirm "${wayland_pkgs[@]}" "${kde_pkgs[@]}"
  #   set_themes() {
  #     # Lightly, for KDE Catppuccin material design: System Settings > Appearance > Application Style > Lightly
  #     pushd "$home/.src" || return
  #     paru -S cmake extra-cmake-modules kdecoration qt5-declarative qt5-x11extras
  #     git clone --single-branch --depth=1 https://github.com/Luwx/Lightly.git
  #     pushd Lightly || return
  #     mkdir build
  #     pushd build || return
  #     cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_TESTING=OFF ..
  #     make
  #     sudo make install
  #     popd || return # Lightly
  #     popd || return # $home/.src
  #     # KDE Catppuccin
  #     git clone https://github.com/catppuccin/kde.git catppuccin-kde
  #     pushd catppuccin-kde/kde-store-archives/global-theme || return
  #     kpackagetool5 -i catppuccin.tar.gz
  #     popd || return # $home/.src
  #     popd || return # $PWD
  #     # VSCode Catppuccin
  #     git clone https://github.com/catppuccin/vscode.git "$home/.vscode/catppuccin-vscode" # then CTRL+K CTRL+T
  #   }

  #   set_themes
  # }

  install_xfce() {
    paru -S --needed --noconfirm "${x11_pkgs[@]}" "${xfce_pkgs[@]}"
  }

  # install_gnome() {}

  # install_cinnamon() {}

  install_i3() {
    paru -S --needed --noconfirm "${x11_pkgs[@]}" "${i3_pkgs[@]}"
  }

  install_sway() {
    paru -S --needed --noconfirm "${wayland_pkgs[@]}" "${sway_pkgs[@]}"
  }

  install_"$GUI"
)

install_locker() {
  echo -e "\nInstalling screen locker\n"
  paru -S --needed --noconfirm betterlockscreen

  # automatically done by the AUR
  #sudo cp "$XDG_CACHE_HOME/paru/clone/betterlockscreen/betterlockscreen@.service" /usr/lib/systemd/system/
  sudo sed -i 's/--lock$/-l blur -q/' /usr/lib/systemd/system/betterlockscreen@.service && sudo systemctl daemon-reload
  # auto-lock screen before sleep/suspend
  sudo systemctl enable betterlockscreen@"$(whoami)"
}

install_programs() {
  paru -S --needed --noconfirm "${pkgs[@]}"
}

install_pymodules() {
  echo -e "\nInstalling Python modules...\n"
}

install_appimages() {
  echo -e "\nInstalling AppImage apps...\n"
  pushd ~/apps || return
  # curl https://download.supernotes.app/Supernotes-2.1.3.AppImage -o Supernotes-2.1.3.AppImage
  chmod u+x ./*
  popd || return
}

set_editors() {
  ## VSCode
  echo -e "\nInstalling VSCode extensions from \"$XDG_CONFIG_HOME/Code - OSS/User/extensions.txt\"\n"
  extdir="$XDG_CONFIG_HOME/Code - OSS/User"
  [ -d "$extdir" ] || { echo "Directory \"$extdir\" doesn't exist, skipping..."; return 1; }
  while read -r ext; do
    echo "Installing $ext..."
    code --install-extension "$ext" &>/dev/null
  done <"$extdir"/extensions.txt
  echo -e "Installing latest C/C++ extension\n"
  pushd ~/.vscode-oss/extensions/ || return 1
  latest=$(curl -s "https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools" | rg "Versions.*?([.0-9]+)" -o -r'$1')
  wget "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cpptools/$latest/vspackage?targetPlatform=linux-x64" -o ms-vscode.cpptools-"$latest".vsix
  code --install-extension ms-vscode.cpptools-"$latest".vsix &>/dev/null
  popd || return 1
  echo "Updating list..."
  code --list-extensions >"$extdir"/extensions.txt
  echo -e "\nDone."

  ## Vim-Plug
  echo -e "\nInstalling Vim-Plug...\n"
  curl -fLo "$XDG_CONFIG_HOME"/vim/autoload/plug.vim --create-dirs \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
}

set_zram() {
  paru -S --needed --noconfirm zramswap
  perc=$1
  echo "ZRAM_SIZE_PERCENT=$perc" | sudo tee /etc/zramswap.conf
  sudo systemctl enable --now zramswap
}

set_virtualization() {
  # manually resolve iptables conflict first
  paru -S --needed iptables-nft
  # qemu/kvm
  paru -S --needed --noconfirm virt-manager qemu qemu-arch-extra virbr0 vde2 edk2-ovmf ebtables dnsmasq bridge-utils openbsd-netcat
  sudo usermod -a -G libvirt,kvm "$(whoami)"
  sudo systemctl enable libvirtd
  sudo systemctl start libvirtd
  # wget https://gitlab.com/eflinux/kvmarch/-/raw/master/br10.xml -O "$XDG_CONFIG_HOME/.br10.xml"
  # sudo virsh net-define "$XDG_CONFIG_HOME/.br10.xml"
  # sudo virsh net-start .br10
  # sudo virsh net-autostart .br10
  # VirtualBox
  paru -S --needed --noconfirm virtualbox virtualbox-host-modules-arch virtualbox-guest-utils virtualbox-guest-iso
}

set_snapper() {
  sudo snapper -c root create-config /
  sudo sed -i -E "s/^(ALLOW_USERS=)\".*"/\1\"$(whoami)\"/" /etc/snapper/configs/root
  sudo sed -i -E 's/^(TIMELINE_LIMIT_HOURLY=)".*"/\1"1"/; s/^(TIMELINE_LIMIT_DAILY=)".*"/\1"3"/; s/^(TIMELINE_LIMIT_WEEKLY=)".*"/\1"7"/; s/^(TIMELINE_LIMIT_MONTHLY=)".*"/\1"4"/; s/^(TIMELINE_LIMIT_YEARLY=)".*"/\1"0"/' /etc/snapper/configs/root
  sudo chmod +rx /.snapshots/
  sudo systemctl enable snapper-{timeline,cleanup}.timer grub-btrfsd.service
}

set_crontab() {
  echo "@reboot dconf dump /org/nemo/ >~/.config/nemo/preferences" | sudo tee /var/spool/cron/"$(whoami)"
}

miscellanea() {
  ## Adjust permissions
  sudo chmod +s /usr/bin/light

  ## Copies
  sudo cp -r "$XDG_DATA_HOME"/icons/* /usr/share/icons/
  sudo cp -r "$XDG_DATA_HOME"/fonts/* /usr/share/fonts/
  sudo cp -r "$XDG_DATA_HOME"/themes/* /usr/share/themes/

  ## packages hard link to ~
  ln -Pf ~/.packages ~/projects/auto-arch/packages

  ## Updates
  fc-cache -fv

  ## Nemo preferences
  dconf dump /org/nemo/ >"$XDG_CONFIG_HOME"/nemo/preferences &

  ## Removals
  rmdir ~/{Public,Templates}

  ## GRUB theme
  sudo cp -r "$XDG_DATA_HOME"/themes/Xenlism-Arch/ /boot/grub/themes/
  sudo sed -i 's/^#\?GRUB_THEME=.*/GRUB_THEME=\"\/boot\/grub\/themes\/Xenlism-Arch\/theme.txt"/' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
}

prepare
install_displaymanager
install_GUI
install_locker
install_programs
install_pymodules
install_appimages
set_editors
set_zram 100
set_virtualization
set_snapper
set_crontab
miscellanea

echo "\nDone! You can now reboot the system."
