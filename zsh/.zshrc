# prevent duplicates in PATH
typeset -U PATH path

# determine OS
[[ `uname` == Darwin ]] && local MacOS
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
HISTSIZE=1000
SAVEHIST=500

if [[ -v MacOS ]]; then
    # on MacOS, want to use the vim as installed by homebrew
    export EDITOR=/usr/local/bin/vim
else
    export EDITOR=/usr/bin/vim
fi
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
alias cp="cp -i"                                                # Confirm before overwriting something
alias ls='ls --color=auto'
alias grep='grep --colour=auto'
alias egrep='egrep --colour=auto'
alias fgrep='fgrep --colour=auto'
# MacOS has builtin open command
[[ ! -v MacOS ]] && alias open='xdg-open'
# MacOS uses not docker for docker
[[ -v MacOS ]] && alias docker='nerdctl.lima'



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
# if [[ -v MacOS ]]; then
#     if command -v brew &> /dev/null; then
#         brew install zsh-syntax-highlighting
#         brew install zsh-history-substring-search
#         brew install zsh-autosuggestions
#     fi
# else
#     # TODO install on linux
# fi

# Use syntax highlighting
if [[ -v MacOS ]]; then
    ZSH_SYNTAX_HIGHLIGHTING="/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
    ZSH_SYNTAX_HIGHLIGHTING="/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
if [[ -f "$ZSH_SYNTAX_HIGHLIGHTING" ]]; then
    source "$ZSH_SYNTAX_HIGHLIGHTING"
else
    echo "NO zsh-syntax-highlighting.zsh found!"
fi

# Use history substring search
if [[ -v MacOS ]]; then
    ZSH_HISTORY_SUBSTRING_SEARCH="/usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
else
    ZSH_HISTORY_SUBSTRING_SEARCH="/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi
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
if [[ -v MacOS ]]; then
    ZSH_AUTOSUGGESTIONS="/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
else
    ZSH_AUTOSUGGESTIONS="/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -f "$ZSH_AUTOSUGGESTIONS" ]]; then
    source "$ZSH_AUTOSUGGESTIONS"
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
else
    echo "No zsh-autosuggestions found!"
fi


## PATH section and settings specific to certain programs
# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init --path)"
    eval "$(pyenv virtualenv-init -)"
fi

# things for building CPython, uncomment when time to install new python versions with pyenv
# build CPython with framework support (OS X)
#export PYTHON_CONFIGURE_OPTS="--enable-framework"
# build CPython as dynamic lib (linux)
#export PYTHON_CONFIGURE_OPTS="--enable-shared"
# for optimized CPython
#export CFLAGS='-O2'

# poetry
export PATH="$HOME/.local/bin:$PATH"

# rust
export PATH="$HOME/.cargo/bin:$PATH"

# go
export PATH="$PATH:/usr/local/go/bin"

# deno
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

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
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# sdkman for java stuff
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
