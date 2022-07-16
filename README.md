# Updating config

```bash
./wsl-arch-dotfiles/setup.sh
```

## Installing new packages

1. Add package to packages list in ./setup.sh
1. (*opt*) Move it's config folder inside the repo's folder
  1. Create symlink (ln -s -f) in the ./setup.sh file
1. Run setup.sh to make sure everything works
1. Commit & push changes.

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

## Setting up git & the repo

```
sudo pacman -S git
git config --global user.email "<email>"
git config --global user.name "<fullname>"
git clone https://github.com/thomasgoulet/wsl-arch-dotfiles
```

### PAT

1. Github.com > Settings > Developper Settings > Personal Access Tokens
2. Create one and copy it
3. Use as password when pushing
