#! /bin/sh

## Set these to 1 if you want to install them
INSTALL_PARU=0
INSTALL_AZCLI=0

## .config symlink

mkdir -p ~/wsl-arch-dotfiles/.config
ln -f --symbolic ~/wsl-arch-dotfiles/.config ~/.config

## Packages

sudo pacman -S btop cargo fish github-cli kubectl man-db micro neofetch neovim node python

## Azure-CLI

if [ $INSTALL_AZCLI -eq 1 ]
then
	curl -L https://aka.ms/InstallAzureCli | bash
fi

## Paru

if [ $INSTALL_PARU -eq 1 ]
then

	sudo pacman -S --needed base-devel
	git clone https://aur.archlinux.org/paru.git
	cd paru
	makepkg -si
	cd ..
	rm -R -f paru

fi

## Paru Packages

if [ $INSTALL_K3D -eq 1 ]
then

  paru -S --skipreview rancher-k3d-bin

fi
