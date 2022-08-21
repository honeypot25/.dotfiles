#!/usr/bin/env bash

source ~/.packages

preparing() {
  # system update
  pacup --needed --noconfirm

  echo -e "\nCreating necessary directories\n"
  pushd ~ || return
  mkdir -p .src .config/mpd/playlists
  mkdir -p apps coding games misc projects uni vms Pictures/{screenshots,wallpapers} Videos/screenrec
  # wallpapers
  git clone https://gitlab.com/dwt1/wallpapers.git ~/Pictures/wallpapers
  # mkdir -p .{fonts,themes,icons} /usr/share/{fonts,themes,icons} /usr/local/bin
  popd || return # $PWD

  # install paru
  echo -e "\nInstalling AUR helper (paru)\n"
  pushd ~/.src || return
  git clone https://aur.archlinux.org/paru-bin
  pushd paru-bin || return
  makepkg -si --noconfirm
  sudo sed -i 's/^#BottomUp/BottomUp/' /etc/paru.conf
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
  while [[ ! "$GUI" =~ ^kde|xfce|gnome|cinnamon|i3|sway$ ]]; do
    read -rp "Install your DE/WM (kde|xfce|gnome|cinnamon|i3|sway): " GUI
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

  # install_xfce() {}

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

install_packages() {
  paru -S --needed --noconfirm "${pkgs[@]}"

  echo -e "Installing VSCode extensions from \"~/.config/Code - OSS/User/extensions.txt\"\n"
  while read -r ext; do
    echo "Installing $ext..."
    code --install-extension "$ext" &>/dev/null
  done <"$HOME/.config/Code - OSS/User/extensions.txt"
  echo -e "\nDone."
}

set_zram() {
  paru -S --needed --noconfirm zramswap
  sudo systemctl enable --now zramswap
  # # zramd
  # read -rp "Enter the max ZRAM size in MB (actual RAM + 1GB, e.g. 8640): " MAX_ZRAM
  # sudo sed -i 's/^# ALGORITHM=.*/ALGORITHM=zstd/' /etc/default/zramd
  # sed -i "s/^# MAX_SIZE=.*/MAX_SIZE=$MAX_ZRAM/" /etc/default/zramd # e.g. if 8.64GB: +1GB than actual RAM (8GiB = 7.64GB)
  # sudo systemctl enable --now zramd
}

set_virtualization() {
  # manually resolve iptables conflict
  paru -S --needed iptables-nft
  paru -S --needed --noconfirm virt-manager qemu qemu-arch-extra vde2 edk2-ovmf ebtables dnsmasq bridge-utils openbsd-netcat
  sudo usermod -a -G libvirt,kvm "$(whoami)"
  sudo systemctl enable libvirtd
  sudo systemctl start libvirtd
  # wget https://gitlab.com/eflinux/kvmarch/-/raw/master/br10.xml -O ~/.config/.br10.xml
  # sudo virsh net-define ~/.config/.br10.xml
  # sudo virsh net-start .br10
  # sudo virsh net-autostart .br10
}

end() {
  # services
  sudo systemctl enable betterlockscreen@"$(whoami)" # auto-lock screen before sleep/suspend
  # adjust permissions
  sudo chmod +s /usr/bin/light
  # copies
  sudo cp -r ~/.fonts/* /usr/share/fonts/
  sudo cp -r ~/.themes/* /usr/share/themes/
  sudo cp -r ~/.icons/* /usr/share/icons/
  ln -Pf ~/.packages ~/projects/auto-arch/packages # hard link
  # updates
  fc-cache -fv
  # removals
  rmdir ~/{Public,Templates}
  # install GRUB theme
  sudo cp -r ~/.themes/Xenlism-Arch/ /boot/grub/themes/
  sudo sed -i 's/^#\?GRUB_THEME=.*/GRUB_THEME=\"\/boot\/grub\/themes\/Xenlism-Arch\/theme.txt"/' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg

  # reboot
  printf "All done!\nRemember to config Timeshift (5, 7, 0, 0, 0)\n\nRebooting in:\n"
  for sec in {10..1}; do
    printf "%s...\n" "$sec"
    sleep 1
  done
  reboot
}

preparing
install_displaymanager
install_GUI
install_packages
set_zram
set_virtualization
# set_timeshift
end
