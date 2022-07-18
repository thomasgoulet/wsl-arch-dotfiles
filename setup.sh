#! /bin/sh

## .config symlink

mkdir -p ~/wsl-arch-dotfiles/.config
ln -f --symbolic ~/wsl-arch-dotfiles/.config ~/.config

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


if [ $INSTALL_LVIM -eq 1 ]
then

  bash (curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | psub)

fi

