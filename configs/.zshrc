# /etc/zsh/zshrc: system-wide .zshrc file for zsh(1).
#
# This file is sourced only for interactive shells. It
# should contain commands to set up aliases, functions,
# options, key bindings, etc.
#
# Global Order: zshenv, zprofile, zshrc, zlogin

READNULLCMD=${PAGER:-/usr/bin/pager}

# aliases
alias ll="ls -lha"
alias ls="ls --color=auto -F"

# history
HISTFILE=~/.bash_history
SAVEHIST=5000
HISTSIZE=5000
setopt APPEND_HISTORY
setopt hist_ignore_all_dups

#prevent particular entries from being recorded when they start with a space
setopt hist_ignore_space

# activate regexp
setopt extendedglob notify
bindkey -e

#
# auto completion
#
autoload -Uz compinit
compinit
setopt autocd
# correct mistakes:
setopt CORRECT
setopt AUTO_LIST
# allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD
# tab completion moves to end of word
setopt ALWAYS_TO_END
setopt listtypes

# allow approximate completion
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# bind keys with own commands
# show correct keycodes for your keyboard with $ sudo showkey
bindkey "^[[1~" beginning-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey "^[OF" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# colorful PS1
autoload colors
colors
export PS1="%B[%{$fg[green]%}%n%{$reset_color%}%b@%B%{$fg[red]%}%m%b%{$reset_color%}:%{$fg[yellow]%}%~%{$reset_color%}%B]%b "

export EDITOR=/usr/bin/vim

# Maven
#export M3_HOME="/usr/local/apache-maven-3.0.5"
#export M3=$M3_HOME/bin
#export PATH=$M3:$PATH

# Java
#export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
#export PATH=$JAVA_HOME/bin:$PATH

#unalias run-help
#autoload run-help
