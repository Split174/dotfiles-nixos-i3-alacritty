#!/bin/bash

mkdir -p ~/dotfiles

sudo mv /etc/nixos ~/dotfiles/

sudo chown -R $(id -un):users ~/dotfiles/nixos

sudo ln -s ~/dotfiles/nixos /etc/

mkdir -p ~/dotfiles/i3

mv ~/.config/i3/config ~/dotfiles/i3/

ln -s ~/dotfiles/i3/config ~/.config/i3/config

mkdir -p ~/dotfiles/i3status

mv ~/.config/i3status/config ~/dotfiles/i3status/

ln -s ~/dotfiles/i3status/config ~/.config/i3status/config