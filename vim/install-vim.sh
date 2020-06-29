#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
	brew install cmake macvim
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
	# maybe set install location first...
	git clone https://github.com/vim/vim
	cd vim
	git pull
fi
