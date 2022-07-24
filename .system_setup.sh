#!/usr/bin/env bash

set -e

create_dirs() {
  echo -e "\nCreating necessary directories\n"
  pushd ~ || return
  mkdir -p .src/paru-bin
  mkdir -p apps coding games media projects uni varie
  mkdir -p Pictures && git clone https://github.com/dwt1/wallpapers.git Pictures/
  popd || return # $PWD
}

get_some_packages() {
  # xdg-ninja
  sudo pacman -S --noconfirm jq
  sudo git clone https://github.com/b3nj5m1n/xdg-ninja /usr/local/bin/xdg-ninja
}

install_aur() {
  # install paru
  echo -e "\nInstalling AUR helper (paru)\n"
  pushd ~/.src/paru-bin || return
  git clone https://aur.archlinux.org/paru-bin
  makepkg -si --noconfirm
  sudo sed -i 's/^#BottomUp/BottomUp/' /etc/paru.conf
  popd || return # $PWD

  shopt -s nocasematch
  while [[ ! "$now_aur" =~ y|n ]]; do
    read -rp "Do you want to install AUR packages now? (y|n): " now_aur
  done
  echo
  shopt -u nocasematch
  if [ "$now_aur" = "y" ]; then
    source ~/.packages
    sudo paru -S --needed --noconfirm "${aur_pkgs[@]}"
  fi
}

install_GUI() (
  # choose GUI
  shopt -s nocasematch
  while [[ ! "$GUI" =~ kde|xfce|gnome|cinnamon|i3|sway ]]; do
    read -rp "Enter a DE/WM (kde|xfce|gnome|cinnamon|i3|sway): " GUI
  done
  echo
  shopt -u nocasematch
  GUI=${GUI,,} # $GUI to lowercase

  ## General
  # set_dunst() {
  #   pushd "$home/.src" || return
  #   git clone https://github.com/dunst-project/dunst.git
  #   pushd dunst || return
  #   make
  #   sudo make install
  #   popd || return # $home/.src
  #   popd || return # $PWD
  # }

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

set_zram() {
  sudo paru -S --noconfirm --needed zramd
  read -rp "Enter the max ZRAM size in MB (actual RAM + 1GB, e.g. 8640): " MAX_ZRAM
  sudo sed -i 's/^# ALGORITHM=.*/ALGORITHM=zstd/' /etc/default/zramd
  sed -i "s/^# MAX_SIZE=.*/MAX_SIZE=$MAX_ZRAM/" /etc/default/zramd # e.g. if 8.64GB: +1GB than actual RAM (8GiB = 7.64GB)
  sudo systemctl enable --now zramd
}

set_timeshift() {
  sudo paru -S --noconfirm --needed timeshift timeshift-autosnap
}

set_virtualization() {
  sudo pacman -S --noconfirm --needed virt-manager qemu qemu-arch-extra ovmf vde2 edk2-ovmf ebtables dnsmasq bridge-utils openbsd-netcat
  sudo usermod -a -G libvirt,kvm $USERNAME
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

create_dirs
get_some_packages
install_aur
install_GUI
set_zram
set_timeshift
set_virtualization
end

#########################################################################################################################

# for @ (root) subvolume
# config_snapper() {
#   sudo umount /.snapshots
#   sudo rm -rf /.snapshots
#   sudo snapper -c root create-config /
#   sudo btrfs subvolume delete /.snapshots
#   sudo mkdir /.snapshots
#   sudo mount -a
#   # so that @ can be easily replaced by @snapshots if needed
#   sudo chmod 750 /.snapshots
#   sudo sed -i "s/^ALLOW_USERS=\"\"/ALLOW_USERS=\"$USER\"/" /etc/snapper/configs/root
#   sudo sed -i 's/^TIMELINE_LIMIT_HOURLY=".*"/TIMELINE_LIMIT_HOURLY="5"/' /etc/snapper/configs/root
#   sudo sed -i 's/^TIMELINE_LIMIT_DAILY=".*"/TIMELINE_LIMIT_DAILY="7"/' /etc/snapper/configs/root
#   sudo sed -i 's/^TIMELINE_LIMIT_WEEKLY=".*"/TIMELINE_LIMIT_WEEKLY="0"/' /etc/snapper/configs/root
#   sudo sed -i 's/^TIMELINE_LIMIT_MONTHLY=".*"/TIMELINE_LIMIT_MONTHLY="0"/' /etc/snapper/configs/root
#   sudo sed -i 's/^TIMELINE_LIMIT_YEARLY=".*"/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/root
#   sudo systemctl --now snapper-timeline.timer snapper-cleanup.timer
# }
# config_snapper

# ----------------------------------------------------------------------------------------

# SHELL := bash

# .PHONY: all
# all: bin usr dotfiles etc ## Installs the bin and etc directory files and the dotfiles.

# .PHONY: bin
# bin: ## Installs the bin directory files.
# 	# add aliases for things in bin
# 	for file in $(shell find $(CURDIR)/bin -type f -not -name "*-backlight" -not -name ".*.swp"); do \
# 		f=$$(basename $$file); \
# 		sudo ln -sf $$file /usr/local/bin/$$f; \
# 	done

# .PHONY: dotfiles
# dotfiles: ## Installs the dotfiles.
# 	# add aliases for dotfiles
# 	for file in $(shell find $(CURDIR) -name ".*" -not -name ".gitignore" -not -name ".git" -not -name ".config" -not -name ".github" -not -name ".*.swp" -not -name ".gnupg"); do \
# 		f=$$(basename $$file); \
# 		ln -sfn $$file $(HOME)/$$f; \
# 	done; \
# 	gpg --list-keys || true;
# 	mkdir -p $(HOME)/.gnupg
# 	for file in $(shell find $(CURDIR)/.gnupg); do \
# 		f=$$(basename $$file); \
# 		ln -sfn $$file $(HOME)/.gnupg/$$f; \
# 	done; \
# 	ln -fn $(CURDIR)/gitignore $(HOME)/.gitignore;
# 	git update-index --skip-worktree $(CURDIR)/.gitconfig;
# 	mkdir -p $(HOME)/.config;
# 	ln -snf $(CURDIR)/.i3 $(HOME)/.config/sway;
# 	mkdir -p $(HOME)/.local/share;
# 	ln -snf $(CURDIR)/.fonts $(HOME)/.local/share/fonts;
# 	ln -snf $(CURDIR)/.bash_profile $(HOME)/.profile;
# 	if [ -f /usr/local/bin/pinentry ]; then \
# 		sudo ln -snf /usr/bin/pinentry /usr/local/bin/pinentry; \
# 	fi;
# 	mkdir -p $(HOME)/Pictures;
# 	ln -snf $(CURDIR)/central-park.jpg $(HOME)/Pictures/central-park.jpg;
# 	mkdir -p $(HOME)/.config/fontconfig;
# 	ln -snf $(CURDIR)/.config/fontconfig/fontconfig.conf $(HOME)/.config/fontconfig/fontconfig.conf;
# 	xrdb -merge $(HOME)/.Xdefaults || true
# 	xrdb -merge $(HOME)/.Xresources || true
# 	fc-cache -f -v || true

# # Get the laptop's model number so we can generate xorg specific files.
# LAPTOP_XORG_FILE=/etc/X11/xorg.conf.d/10-dell-xps-display.conf

# .PHONY: etc
# etc: ## Installs the etc directory files.
# 	sudo mkdir -p /etc/docker/seccomp
# 	for file in $(shell find $(CURDIR)/etc -type f -not -name ".*.swp"); do \
# 		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
# 		sudo mkdir -p $$(dirname $$f); \
# 		sudo ln -f $$file $$f; \
# 	done
# 	systemctl --user daemon-reload || true
# 	sudo systemctl daemon-reload
# 	sudo systemctl enable systemd-networkd systemd-resolved
# 	sudo systemctl start systemd-networkd systemd-resolved
# 	sudo ln -snf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
# 	LAPTOP_MODEL_NUMBER=$$(sudo dmidecode | grep "Product Name: XPS 13" | sed "s/Product Name: XPS 13 //" | xargs echo -n); \
# 	if [[ "$$LAPTOP_MODEL_NUMBER" == "9300" ]]; then \
# 		sudo ln -snf "$(CURDIR)/etc/X11/xorg.conf.d/dell-xps-display-9300" "$(LAPTOP_XORG_FILE)"; \
# 	else \
# 		sudo ln -snf "$(CURDIR)/etc/X11/xorg.conf.d/dell-xps-display" "$(LAPTOP_XORG_FILE)"; \
# 	fi

# .PHONY: usr
# usr: ## Installs the usr directory files.
# 	for file in $(shell find $(CURDIR)/usr -type f -not -name ".*.swp"); do \
# 		f=$$(echo $$file | sed -e 's|$(CURDIR)||'); \
# 		sudo mkdir -p $$(dirname $$f); \
# 		sudo ln -f $$file $$f; \
# 	done

# .PHONY: test
# test: shellcheck ## Runs all the tests on the files in the repository.

# # if this session isn't interactive, then we don't want to allocate a
# # TTY, which would fail, but if it is interactive, we do want to attach
# # so that the user can send e.g. ^C through.
# INTERACTIVE := $(shell [ -t 0 ] && echo 1 || echo 0)
# ifeq ($(INTERACTIVE), 1)
# 	DOCKER_FLAGS += -t
# endif

# .PHONY: shellcheck
# shellcheck: ## Runs the shellcheck tests on the scripts.
# 	docker run --rm -i $(DOCKER_FLAGS) \
# 		--name df-shellcheck \
# 		-v $(CURDIR):/usr/src:ro \
# 		--workdir /usr/src \
# 		jess/shellcheck ./test.sh

# .PHONY: help
# help:
# 	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
