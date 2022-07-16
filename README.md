# Arch WSL Install

## Downloading & Installing Arch

[GitHub repo with instructions](https://github.com/yuk7/ArchWSL#install)

## Setting up user account

```bash
nano /etc/sudoers
```
Uncomment `%wheel   ALL=(ALL)   ALL`

```bash
useradd -m thomas -G wheel
passwd thomas
su thomas
cd /home/thomas
```

## Setting up pacman

```bash
sudo pacman-key --init
sudo pacman-key --populate
sudo pacman -Syy archlinux-keyring
sudo pacman -Syyu
```

## Setupping this repo git

```
sudo pacman -S git
git clone https://github.com/thomasgoulet/wsl-arch-dotfiles
```
