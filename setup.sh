#! /bin/sh

## .config symlink

mkdir -p ~/wsl-arch-dotfiles/.config
ln -f --symbolic ~/wsl-arch-dotfiles/.config ~/.config

if [ $INSTALL_PARU -eq 1 ]
then

	sudo pacman -S --needed base-devel
	git clone https://aur.archlinux.org/paru.git
	cd paru
	makepkg -si
	cd ..
	rm -R -f paru

fi
