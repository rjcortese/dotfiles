# vim
A script to easily install vim with the settings that I like.
This is motivated by the desire to easily install the YouCompleteMe plugin.
It should work multiplatform (Windows, OSX, Ubuntu).


## install vim
### OSX
The script should install MacVim using brew commands.

### Windows
The script should install gvim.

### Ubuntu
The script should clone the git repo and build from source.


## vimrc
### Unix
`curl -o ~/.vimrc https://raw.githubusercontent.com/rjcortese/vimrc/master/.vimrc`

### Windows
`curl -o _vimrc https://raw.githubusercontent.com/rjcortese/vimrc/master/_vimrc`

### If things break...
It is probably because YCM `install.py` is being called with options for languages that aren't installed.
Try `python install.py` with no args to do a basic install.
TODO: auto check what is installed and modify the install args accordingly.
