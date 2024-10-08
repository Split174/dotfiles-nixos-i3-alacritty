#!/bin/bash

mkdir -p ~/dotfiles

# Перемещение конфигурации NixOS
sudo mv /etc/nixos ~/dotfiles/
sudo chown -R $(id -un):users ~/dotfiles/nixos
sudo ln -s ~/dotfiles/nixos /etc/

# Обработка конфигурации i3
mkdir -p ~/dotfiles/i3
mv ~/.config/i3/config ~/dotfiles/i3/
ln -s ~/dotfiles/i3/config ~/.config/i3/config

# Обработка конфигурации i3status
mkdir -p ~/dotfiles/i3status
mv ~/.config/i3status/config ~/dotfiles/i3status/
ln -s ~/dotfiles/i3status/config ~/.config/i3status/config

# Обработка конфигурации alacritty
mkdir -p ~/dotfiles/alacritty
mv ~/.config/alacritty/alacritty.yml ~/dotfiles/alacritty/
ln -s ~/dotfiles/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml