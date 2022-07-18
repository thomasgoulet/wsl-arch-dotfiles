#! /bin/sh

pacman -Qqe | grep -v "$(pacman -Qqm)" > pacman.pak
pacman -Qqm > aur.pak

