#!/usr/bin/env zsh
curl -L -o alacritty.info "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info"
sudo tic -xe alacritty,alacritty-direct alacritty.info && rm alacritty.info
