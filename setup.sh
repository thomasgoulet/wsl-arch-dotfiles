#! /bin/sh

# .config symlink

mkdir -p ~/wsl-arch-dotfiles/.config
ln -f --symbolic ~/wsl-arch-dotfiles/.config ~/.config

# Paru

## Set this to 1 to install paru
PARU_INSTALL=0

if [ $PARU_INSTALL -eq 1 ]
then

	sudo pacman -S --needed base-devel
	git clone https://aur.archlinux.org/paru.git
	cd paru
	makepkg -si
	cd ..
	rm -R -f paru

fi


# Packages

sudo pacman -S fish github-cli man-db neofetch python
