#! /bin/sh

pacman -S --needed --noconfirm - < pacman.pak
paru -S --needed - < aur.pak

