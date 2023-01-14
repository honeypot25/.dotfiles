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
  # git clone https://gitlab.com/dwt1/wallpapers.git ~/Pictures/wallpapers
  # system
  mkdir "$XDG_STATE_HOME/bash"
  mkdir "$XDG_DATA_HOME/{cargo,gnupg,pki}"
  mkdir "$XDG_CONFIG_HOME/python"
  popd || return # $PWD

  # install paru
  echo -e "\nInstalling AUR helper (paru)\n"
  pushd ~/.src || return
  git clone https://aur.archlinux.org/paru
  pushd paru || return
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
    # .Xauthority XDG-compliance
    sudo sed -i '/[LightDM]/a user-authority-in-system-dir=true' /etc/lightdm/lightdm.conf
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
  # kde|xfce|gnome|cinnamon|sway
  while [[ ! "$GUI" =~ ^kde|i3$ ]]; do
    # kde|xfce|gnome|cinnamon|sway
    read -rp "Install your DE/WM (i3): " GUI
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
  echo -e "Installing latest C/C++ extension\n"
  pushd ~/.vscode-oss/extensions/ || return
  latest=$(curl -s "https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools" | rg "Versions.*?([.0-9]+)" -o -r'$1')
  wget "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cpptools/$latest/vspackage?targetPlatform=linux-x64" -o ms-vscode.cpptools-"$latest".vsix
  code --install-extension ms-vscode.cpptools-"$latest".vsix &>/dev/null
  popd || return
  echo -e "\nDone."

  echo -e "\nInstalling AppImage apps...\n"
  pushd ~/apps || return
  curl https://download.supernotes.app/Supernotes-2.1.3.AppImage -o Supernotes-2.1.3.AppImage
  chmod u+x ./*
  popd || return

  echo -e "\nInstalling Python modules...\n"
  pip install neovim

  echo -e "\nInstalling Vim-Plug...\n"
  curl -fLo "${XDG_DATA_HOME:-~/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
}

set_zram() {
  paru -S --needed --noconfirm zramswap
  # 50% RAM
  echo "ZRAM_SIZE_PERCENT=50" | sudo tee /etc/zramswap.conf
  sudo systemctl enable --now zramswap
}

set_virtualization() {
  # manually resolve iptables conflict
  paru -S --needed iptables-nft
  # qemu/kvm
  paru -S --needed --noconfirm virt-manager qemu qemu-arch-extra virbr0 vde2 edk2-ovmf ebtables dnsmasq bridge-utils openbsd-netcat
  sudo usermod -a -G libvirt,kvm "$(whoami)"
  sudo systemctl enable libvirtd
  sudo systemctl start libvirtd
  # wget https://gitlab.com/eflinux/kvmarch/-/raw/master/br10.xml -O ~/.config/.br10.xml
  # sudo virsh net-define ~/.config/.br10.xml
  # sudo virsh net-start .br10
  # sudo virsh net-autostart .br10
  # VirtualBox
  # paru -S --needed --noconfirm virtualbox virtualbox-guest-utils
}

# set_crontab() {
#   {
#     echo ""
#   } | sudo tee var/spool/cron/"$(whoami)"
# }

end() {
  # services
  sudo systemctl enable betterlockscreen@"$(whoami)" # auto-lock screen before sleep/suspend
  # adjust permissions
  sudo chmod +s /usr/bin/light
  # copies
  sudo cp -r "$XDG_DATA_HOME"/icons/* /usr/share/icons/
  sudo cp -r "$XDG_DATA_HOME"/fonts/* /usr/share/fonts/
  sudo cp -r "$XDG_DATA_HOME"/themes/* /usr/share/themes/
  ln -Pf ~/.packages ~/projects/auto-arch/packages # hard link
  # updates
  fc-cache -fv
  # Nemo preferences
  dconf dump /org/nemo/ >~/.config/nemo/preferences &
  # VScode extensions' list
  code --list-extensions >"$HOME/.config/Code - OSS/User/extensions.txt"
  # removals
  rmdir ~/{Public,Templates}
  # install GRUB theme
  sudo cp -r "$XDG_DATA_HOME/themes/Xenlism-Arch/" /boot/grub/themes/
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
# set_crontab
end
