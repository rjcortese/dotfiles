# prevent duplicates in PATH
typeset -U PATH path

# determine OS
export OSNAME=$(uname)
[[ $OSNAME == Darwin ]] && local MacOS

# use brew on MacOS
# programs installed with brew may depend on this... for example tmux
if [[ -v MacOS ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="$PATH:/opt/homebrew/bin"
fi

# start ssh-agent
# do it before tmux because we want tmux to inherit the env vars
[[ ! -f ~/.ssh/agent/shared_info ]] && ssh-agent -s >~/.ssh/agent/shared_info
# sometimes it ends up existing but being empty so we do this
[[ -z $(cat ~/.ssh/agent/shared_info) ]] && ssh-agent -s >~/.ssh/agent/shared_info
# the agent should be running now so we put add the variables to the environment
eval $(cat ~/.ssh/agent/shared_info) >/dev/null
if ! kill -0 $SSH_AGENT_PID 2>/dev/null; then
    ssh-agent -s >~/.ssh/agent/shared_info
    eval $(cat ~/.ssh/agent/shared_info) >/dev/null
fi

# set EDITOR before tmux too because we want tmux to inherit it
if [[ -v MacOS ]]; then
    # on MacOS, want to use the nvim as installed by homebrew
    export EDITOR=/usr/local/bin/nvim
else
    export EDITOR=/bin/nvim
fi

# start tmux
#
# different ways to determine if tmux should be started:
# if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
#   exec tmux
# fi
#
# if running a graphical environment or MacOS
if [[ $DISPLAY || -v MacOS ]]; then
    # If not running interactively, don't do anything
    # another way to determine if interactive shell on zsh
    # [[ -o interactive ]]
    [[ $- != *i* ]] && return
    # check if tmux is installed and not already in a session
    if command -v tmux &> /dev/null && test -z "$TMUX"; then
        tmux attach -t default || tmux new -s default
    fi

    # when quitting tmux, try to attach
    while test -z "$TMUX"; do
        tmux attach -t default || break
    done
fi

## Options section
unsetopt correct                                                # no autocorrection
unsetopt nomatch                                                # 
setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
setopt nocaseglob                                               # Case insensitive globbing
setopt rcexpandparam                                            # Array expension with parameters
setopt nocheckjobs                                              # Don't warn about running processes when exiting
setopt numericglobsort                                          # Sort filenames numerically when it makes sense
setopt nobeep                                                   # No beep
setopt appendhistory                                            # Immediately append history instead of overwriting
setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
setopt autocd                                                   # if only directory path is entered, cd there.

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                              # automatically find new executables in path 
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

HISTFILE=~/.zhistory
HISTSIZE=100000
SAVEHIST=500

WORDCHARS=${WORDCHARS//\/[&.;]}                                 # Don't consider certain characters part of the word


## Keybindings section
bindkey -e
bindkey '^[[7~' beginning-of-line                               # Home key
bindkey '^[[H' beginning-of-line                                # Home key
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line                # [Home] - Go to beginning of line
fi
bindkey '^[[8~' end-of-line                                     # End key
bindkey '^[[F' end-of-line                                     # End key
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}" end-of-line                       # [End] - Go to end of line
fi
bindkey '^[[2~' overwrite-mode                                  # Insert key
bindkey '^[[3~' delete-char                                     # Delete key
bindkey '^[[C'  forward-char                                    # Right key
bindkey '^[[D'  backward-char                                   # Left key
bindkey '^[[5~' history-beginning-search-backward               # Page up key
bindkey '^[[6~' history-beginning-search-forward                # Page down key

# Navigate words with ctrl+arrow keys
bindkey '^[Oc' forward-word                                     #
bindkey '^[Od' backward-word                                    #
bindkey '^[[1;5D' backward-word                                 #
bindkey '^[[1;5C' forward-word                                  #
bindkey '^H' backward-kill-word                                 # delete previous word with ctrl+backspace
bindkey '^[[Z' undo                                             # Shift+tab undo last action

## Alias section 
alias cp='cp -i'                                                # Confirm before overwriting something
alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
alias vimdiff='nvim -d'
alias vim='nvim'
alias vi='nvim'
# MacOS has builtin open command
[[ ! -v MacOS ]] && alias open='xdg-open'
# MacOS uses not docker for docker
[[ -v MacOS ]] && alias docker='podman'



# Theming section
autoload -U compinit colors zcalc
compinit -d
colors

# enable substitution for prompt
setopt prompt_subst


# Set our Left Promt to the Maia prompt
PROMPT="%B%{$fg[cyan]%}%(4~|%-1~/.../%2~|%~)%u%b >%{$fg[cyan]%}>%B%(?.%{$fg[cyan]%}.%{$fg[red]%})>%{$reset_color%}%b "

## Prompt on right side:
#  - shows status of git when in git repository (code adapted from https://techanic.net/2012/12/30/my_git_prompt_for_zsh.html)
#  - shows exit status of previous command (if previous command finished with an error)
#  - is invisible, if neither is the case

# Modify the colors and symbols in these variables as desired.
GIT_PROMPT_SYMBOL="%{$fg[blue]%}±"                              # plus/minus     - clean repo
GIT_PROMPT_PREFIX="%{$fg[green]%}[%{$reset_color%}"
GIT_PROMPT_SUFFIX="%{$fg[green]%}]%{$reset_color%}"
GIT_PROMPT_AHEAD="%{$fg[red]%}ANUM%{$reset_color%}"             # A"NUM"         - ahead by "NUM" commits
GIT_PROMPT_BEHIND="%{$fg[cyan]%}BNUM%{$reset_color%}"           # B"NUM"         - behind by "NUM" commits
GIT_PROMPT_MERGING="%{$fg_bold[magenta]%}⚡︎%{$reset_color%}"     # lightning bolt - merge conflict
GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}●%{$reset_color%}"       # red circle     - untracked files
GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}●%{$reset_color%}"     # yellow circle  - tracked files modified
GIT_PROMPT_STAGED="%{$fg_bold[green]%}●%{$reset_color%}"        # green circle   - staged changes present = ready for "git push"

parse_git_branch() {
  # Show Git branch/tag, or name-rev if on detached head
  ( git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD ) 2> /dev/null
}

parse_git_state() {
  # Show different symbols as appropriate for various Git repository states
  # Compose this value via multiple conditional appends.
  local GIT_STATE=""
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_AHEAD//NUM/$NUM_AHEAD}
  fi
  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_STATE=$GIT_STATE${GIT_PROMPT_BEHIND//NUM/$NUM_BEHIND}
  fi
  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MERGING
  fi
  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_UNTRACKED
  fi
  if ! git diff --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_MODIFIED
  fi
  if ! git diff --cached --quiet 2> /dev/null; then
    GIT_STATE=$GIT_STATE$GIT_PROMPT_STAGED
  fi
  if [[ -n $GIT_STATE ]]; then
    echo "$GIT_PROMPT_PREFIX$GIT_STATE$GIT_PROMPT_SUFFIX"
  fi
}

git_prompt_string() {
  local git_where="$(parse_git_branch)"
  
  # If inside a Git repository, print its branch and state
  [ -n "$git_where" ] && echo "$GIT_PROMPT_SYMBOL$(parse_git_state)$GIT_PROMPT_PREFIX%{$fg[yellow]%}${git_where#(refs/heads/|tags/)}$GIT_PROMPT_SUFFIX"
  
  # If not inside the Git repo, print exit codes of last command (only if it failed)
  [ ! -n "$git_where" ] && echo "%{$fg[red]%} %(?..[%?])"
}

RPROMPT='$(git_prompt_string)'


# Print some system information when the shell is first started
if [[ -v MacOS ]]; then
    echo $USER@$HOST $(uname -srm) $(sw_vers | awk '{printf "%s ", $2} END {print ""}')
else
    echo $USER@$HOST  $(uname -srm) $(lsb_release -rcs)
fi


# Color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r



## Plugins section:

# try to install needed plugins if we don't have them:
if [[ -v MacOS ]]; then
    if command -v brew &> /dev/null; then
        brew list zsh-syntax-highlighting &> /dev/null || brew install zsh-syntax-highlighting
        brew list zsh-history-substring-search &> /dev/null || brew install zsh-history-substring-search
        brew list zsh-autosuggestions &> /dev/null || brew install zsh-autosuggestions

        ZSH_PLUGIN_DIR="/opt/homebrew/share"
    fi
else
    # Manjaro (arch based) :)
    if command -v pacman &> /dev/null; then
        pacman -Qs zsh-syntax-highlighting &> /dev/null || sudo pacman -S zsh-syntax-highlighting
        pacman -Qs zsh-history-substring-search &> /dev/null || sudo pacman -S zsh-history-substring-search
        pacman -Qs zsh-autosuggestions &> /dev/null || sudo pacman -S zsh-autosuggestions

        ZSH_PLUGIN_DIR="/usr/share/zsh/plugins"

    # Asahi (fedora based) :)
    elif command -v dnf &> /dev/null; then
        dnf list installed zsh-syntax-highlighting &> /dev/null || sudo dnf install zsh-syntax-highlighting
        # this doesn't exist for fedora
        # dnf list installed zsh-history-substring-search &> /dev/null || sudo dnf install zsh-history-substring-search
        dnf list installed zsh-autosuggestions &> /dev/null || sudo dnf install zsh-autosuggestions

        ZSH_PLUGIN_DIR="/usr/share"
    fi
fi

ZSH_SYNTAX_HIGHLIGHTING="${ZSH_PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [[ -f "$ZSH_SYNTAX_HIGHLIGHTING" ]]; then
    source "$ZSH_SYNTAX_HIGHLIGHTING"
else
    echo "NO zsh-syntax-highlighting.zsh found!"
fi

# Use history substring search
ZSH_HISTORY_SUBSTRING_SEARCH="${ZSH_PLUGIN_DIR}/zsh-history-substring-search/zsh-history-substring-search.zsh"
if [[ -f "$ZSH_HISTORY_SUBSTRING_SEARCH" ]]; then
    source "$ZSH_HISTORY_SUBSTRING_SEARCH"

    # bind UP and DOWN arrow keys to history substring search
    zmodload zsh/terminfo
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey "$terminfo[kcud1]" history-substring-search-down
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
else
    echo "NO zsh-history-substring-search.zsh found!"
fi

# Use autosuggestion
ZSH_AUTOSUGGESTIONS="${ZSH_PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"
if [[ -f "$ZSH_AUTOSUGGESTIONS" ]]; then
    source "$ZSH_AUTOSUGGESTIONS"
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
else
    echo "No zsh-autosuggestions found!"
fi

## PATH section and settings specific to certain programs
# pyenv
if [[ -d "$HOME/.pyenv" ]]; then
    export PATH="$HOME/.pyenv/bin:$PATH"
    if command -v pyenv &>/dev/null; then
        eval "$(pyenv init --path)"
        eval "$(pyenv virtualenv-init -)"
    fi
fi

# things for building CPython, uncomment when time to install new python versions with pyenv
# build CPython with framework support (OS X)
#export PYTHON_CONFIGURE_OPTS="--enable-framework"
# build CPython as dynamic lib (linux)
#export PYTHON_CONFIGURE_OPTS="--enable-shared"
# for optimized CPython
#export CFLAGS='-O2'

# some things (poetry and zig) live in ~/.local/bin
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# rust things live in ~/.cargo/bin
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH"

# go
[[ -d "/usr/local/go/bin" ]] && export PATH="$PATH:/usr/local/go/bin"

# deno
if [[ -d "$HOME/.deno" ]]; then
    export DENO_INSTALL="$HOME/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
fi

# places to look for libraries on linux, uncomment if need to build some C stuff...
# LD_LIBRARY_PATH is for linking at runtime
#export LD_LIBRARY_PATH="/usr/lib:/usr/lib32:/usr/lib64:/home/rjcortese/.local/lib"
# LIBRARY_PATH is for linking at compile time (at least for gcc)
#export LIBRARY_PATH="$LD_LIBRARY_PATH"
#
# places to look for libraries on MacOS, uncomment if need to build some C stuff...
# LD_LIBRARY_PATH is for linking at runtime
# export LD_LIBRARY_PATH="/usr/local/lib"
# -I/usr/local/include -L/usr/local/lib -lpostal

# nvm
if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

# bun
if [[ -d "$HOME/.bun" ]]; then
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    # bun completions
    [[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"
fi

# sdkman for java stuff
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

