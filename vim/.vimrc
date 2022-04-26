" a very peachy .vimrc file!

" check the os
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

" download duoduo colorscheme if not downloaded
if g:os == "Windows"
    if empty(glob('C:\Program Files (x86)\Vim\vimfiles\colors\duoduo.vim'))
        silent !mkdir "C:\Program Files (x86)\Vim\vimfiles\colors"
        silent !bitsadmin /transfer duoduoDL /download /priority normal
            \ https://raw.githubusercontent.com/Yggdroot/duoduo/master/colors/duoduo.vim
            \ "C:\Program Files (x86)\Vim\vimfiles\colors\duoduo.vim"
    endif
else
    if empty(glob('~/.vim/colors/duoduo.vim'))
        silent !curl -fLo ~/.vim/colors/duoduo.vim --create-dirs
            \ https://raw.githubusercontent.com/Yggdroot/duoduo/master/colors/duoduo.vim
    endif
endif

" download vim-plug if not already installed
if g:os == "Windows"
    " windows
    if empty(glob('C:\Program Files (x86)\Vim\vimfiles\autoload\plug.vim'))
        silent !mkdir "C:\Program Files (x86)\Vim\vimfiles\autoload"
        silent !bitsadmin /transfer vimplugDL /download /priority normal 
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
            \ "C:\Program Files (x86)\Vim\vimfiles\autoload\plug.vim"
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
else
    " macOS and linux
    if empty(glob('~/.vim/autoload/plug.vim'))
        silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif
endif


" plugins"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set big plug timeout for big plugs
let g:plug_timeout = 10000

" a function to build YCM plugin
function! BuildYCM(info)
	"info is a dictionary with 3 fields:
	" - name: name of plugin
	" - status: 'installed', 'updated', or 'unchanged'
	" - force: set on PlugInstall! or PlugUpdate!
	if a:info.status == 'installed' || a:info.force
		!python ~/.vim/plugged/YouCompleteMe/install.py --clangd-completer --go-completer --ts-completer --rust-completer
	endif
endfunction


if g:os == "Windows"
    call plug#begin('C:\Program Files (x86)\Vim\vimfiles\plugged')
else
    call plug#begin('~/.vim/plugged')
endif

" auto-complete
Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }

" ez commenting / uncommenting
Plug 'tpope/vim-commentary'
" ez work with different case conventions
Plug 'tpope/vim-abolish'
" ez work with surrounding quotes / tags
Plug 'tpope/vim-surround'

" fast folding
Plug 'Konfekt/FastFold'

" python code folding
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }

" python auto-indetation
Plug 'vim-scripts/indentpython.vim', { 'for': 'python' }

" syntax highlighting plugs
Plug 'evanleck/vim-svelte', { 'for': 'svelte' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'keith/swift.vim', { 'for': 'swift' }
Plug 'cespare/vim-toml', { 'for': 'toml' }

" paste from clipboard without having to toggle paste mode
Plug 'ConradIrwin/vim-bracketed-paste'

" rust stuff
Plug 'rust-lang/rust.vim'

" vim-tmux pane nav
Plug 'christoomey/vim-tmux-navigator'

call plug#end()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" YCM options
if g:os == "Windows"
    let g:ycm_clangd_binary_path = "" " TODO: set windows path for clangd (or windows equivalent)
else
    let g:ycm_clangd_binary_path = "/usr/local/opt/llvm/bin/clangd"
endif

let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_auto_trigger = 1

map <leader>g :YcmCompleter GoTo<CR>
map <leader>r :YcmCompleter GoToReferences<CR>
map <leader>i :YcmCompleter GoToImplementation<CR>
map <leader>t :YcmCompleter GoToType<CR>
map <leader>y :YcmCompleter GetType<CR>

" Find correct python path across pyenv / pipenv
"  might be slow...
let pipenv_venv_path = system('pipenv --venv')
if shell_error == 0
    let venv_path = substitute(pipenv_venv_path, '\n', '', '')
    let g:ycm_python_binary_path = venv_path . '/bin/python'
else
    let g:ycm_python_binary_path = 'python3'
endif

" arbitrary language servers
" bash
" install with:
" npm i -g bash-language-server
" then make sure that it is in PATH
let g:ycm_language_server =
    \ [
    \   {
    \       'name': 'bash',
    \       'cmdline': ['bash-language-server', 'start'],
    \       'filetypes': ['bash', 'sh']
    \   }
    \ ]


" Global / default settings
" Use Vim defaults (as opposed to Vi)
set nocompatible
set encoding=utf-8

" allow backspacing over everything in insert mode
set bs=2

" allow cursor to move one spot past end of line
set virtualedit+=onemore

" highlight searches
set hlsearch

" incremental searches
set incsearch

" status line looks like:
set statusline=%<%f%m%r%y=%b\ 0x%B\ \ %l,%c%V\ %P

" always display status line
set laststatus=2

" split below and right
set splitbelow
set splitright

" enable folding
set foldmethod=indent
set foldlevel=99

" use system clipboard
if g:os == "Darwin" || g:os == "Windows"
    set clipboard=unnamed
elseif g:os == "Linux"
    set clipboard=unnamedplus
endif


" color scheme'n
colorscheme duoduo


" Filetype specific settings (mostly for tab size, spacing, etc)
" default
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4

" Python
au BufNewFile,BufRead *.py
    \ set tabstop=4 | " PEP 8
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |
    \ let python_highlight_all = 1 " python syntax highlighting

" Javascript, HTML, CSS, JSON, svelte, xml
au BufNewFile,BufRead *.js,*.html,*.css,*.json,*.svelte,*.xml
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

" C / C++
au BufNewFile,BufRead *.c,*.cc,*.cxx,*.h,*.cpp,*.hpp,CMakeLists.txt
    \ set cindent | " turn on autoindent c style
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2

" bash / sh
au BufNewFile,BufRead *.bash,*.sh
    \ set tabstop=4 |
    \ set expandtab |
    \ set softtabstop=4 |
    \ set shiftwidth=4

" yaml
au BufNewFile,BufRead *.yml,*.yaml
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2


" key remappings
" keep cursor centered vertically even if near EOF (All of these commands do
" vertical movement)
nnoremap j jzz
nnoremap k kzz
nnoremap G Gzz
nnoremap { {zz
nnoremap } }zz
nnoremap n nzz
nnoremap N Nzz
nnoremap % %zz
" and some of the same but for Visual mode
xnoremap j jzz
xnoremap k kzz
xnoremap G Gzz


" simpler movement between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-L> <C-W><C-L>

" toggle fold with space
nnoremap <space> za

" set font on gvim
if has("gui_running")
    set guifont=Consolas:h11:cANSI
endif
