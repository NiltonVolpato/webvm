# Zsh configuration

# History
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space

# Prompt with git branch if available
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PS1='%F{green}%n@webvm%f:%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f$ '

# Enable colors
autoload -U colors && colors

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Key bindings (emacs style)
bindkey -e
bindkey '^[[A' up-line-or-history
bindkey '^[[B' down-line-or-history
bindkey '^[[C' forward-char
bindkey '^[[D' backward-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

