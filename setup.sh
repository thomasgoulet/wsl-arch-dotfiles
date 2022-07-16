#! /bin/sh

# .config symlink

mkdir -p ~/wsl-arch-dotfiles/.config
ln -f --symbolic ~/wsl-arch-dotfiles/.config ~/.config

# Packages

sudo pacman -S man-db
