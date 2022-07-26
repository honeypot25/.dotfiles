#!/usr/bin/env bash

set -e

source ~/.packages

preparing() {
  echo -e "\nCreating necessary directories\n"
  pushd ~ || return
  mkdir -p .src/paru-bin
  mkdir -p apps coding games media projects uni varie
  mkdir -p Pictures && git clone https://gitlab.com/dwt1/wallpapers.git Pictures/
  popd || return # $PWD

  # install paru
  echo -e "\nInstalling AUR helper (paru)\n"
  pushd ~/.src/paru-bin || return
  git clone https://aur.archlinux.org/paru-bin
  makepkg -si --noconfirm
  sudo sed -i 's/^#BottomUp/BottomUp/' /etc/paru.conf
  popd || return # $PWD
}

install_GUI() (
  # choose GUI
  shopt -s nocasematch
  while [[ ! "${GUI,,}" =~ ^(kde|xfce|gnome|cinnamon|i3|sway)$ ]]; do
    read -rp "Install your DE/WM (kde|xfce|gnome|cinnamon|i3|sway): " GUI
  done
  echo
  shopt -u nocasematch
  GUI=${GUI,,} # $GUI to lowercase

  # install_kde() (
  #   # packages
  #   sudo pacman -S --needed --noconfirm "${kde_pkgs[@]}"
  #   # services
  #   sudo systemctl enable sddm
  #   set_themes() {
  #     # Lightly, for KDE Catppuccin material design: System Settings > Appearance > Application Style > Lightly
  #     pushd "$home/.src" || return
  #     sudo pacman -S cmake extra-cmake-modules kdecoration qt5-declarative qt5-x11extras
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
  #   set_dunst
  # )

  # install_xfce() {}

  # install_gnome() {}

  # install_cinnamon() {}

  install_i3() {
    # pacman
    sudo pacman -S --needed --noconfirm "${i3_pkgs[@]}"
    sudo paru -S --noconfirm --needed "${i3_aur_pkgs[@]}"
    # configs
    sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
    # services
    sudo systemctl enable lightdm
  }

  # install_sway() {
  #   # pacman
  #   sudo pacman -S --needed --noconfirm "${sway_pkgs[@]}"
  #   sudo paru -S --noconfirm --needed "${sway_aur_pkgs[@]}"
  #   # configs
  #   sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf
  #   # services
  #   sudo systemctl enable lightdm
  # }

  install_"$GUI"
)

install_packages() {
  ## pacman
  # full system update
  sudo pacman -Syu
  # packages
  sudo pacman -S --needed --noconfirm "${pacman_pkgs[@]}"

  ## MISC
  # xdg-ninja
  sudo pacman -S --noconfirm jq
  sudo git clone https://github.com/b3nj5m1n/xdg-ninja /usr/local/bin/xdg-ninja
}

install_AUR_packages() {
  shopt -s nocasematch
  # now_aur to lowercase
  while [[ ! "${now_aur,,}" =~ ^(y|n)$ ]]; do
    read -rp "Do you want to install your AUR packages now? (y|n): " now_aur
  done
  echo
  shopt -u nocasematch

  if [ "${now_aur,,}" = "y" ]; then
    sudo paru -S --needed --noconfirm "${aur_pkgs[@]}"
  fi
}

set_zram() {
  sudo paru -S --noconfirm --needed zramswap
  sudo systemctl enable --now zramswap
  # # zramd
  # read -rp "Enter the max ZRAM size in MB (actual RAM + 1GB, e.g. 8640): " MAX_ZRAM
  # sudo sed -i 's/^# ALGORITHM=.*/ALGORITHM=zstd/' /etc/default/zramd
  # sed -i "s/^# MAX_SIZE=.*/MAX_SIZE=$MAX_ZRAM/" /etc/default/zramd # e.g. if 8.64GB: +1GB than actual RAM (8GiB = 7.64GB)
  # sudo systemctl enable --now zramd
}

set_virtualization() {
  sudo pacman -S --noconfirm --needed virt-manager qemu qemu-arch-extra vde2 edk2-ovmf ebtables dnsmasq bridge-utils openbsd-netcat
  sudo usermod -a -G libvirt,kvm "$USERNAME"
  sudo systemctl enable libvirtd && sudo systemctl start libvirtd
  # wget https://gitlab.com/eflinux/kvmarch/-/raw/master/br10.xml -O ~/.config/.br10.xml
  sudo virsh net-define ~/.config/.br10.xml && sudo virsh net-start .br10 && sudo virsh net-autostart .br10
}

end() {
  #cd ~ && rm -rf ~/gui
  printf "All done!\nRemember to open and config Timeshift after reboot (with 5, 7, 0, 0, 0)\nRebooting in "
  for sec in {10..1}; do
    printf "%s...\n" "$sec"
    sleep 1
  done
  reboot
}

preparing
install_GUI
install_packages
install_AUR_packages
set_zram
set_timeshift
set_virtualization
end
