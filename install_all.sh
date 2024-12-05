#!/usr/bin/env bash

# alacritty
mkdir -p ~/.config/alacritty 
cp ./alacritty/alacritty.toml ~/.config/alacritty/.
./alacritty/install_terminfo.sh

# tmux
mkdir -p ~/.config/tmux
cp ./tmux/tmux.conf ~/.config/tmux/.

# neovim
mkdir -p ~/.config/nvim
cp -r ./neovim/* ~/.config/nvim/.

# zsh
cp ./zsh/.zshrc ~/.
