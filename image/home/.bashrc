# ~/.bashrc

# History
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Prompt
PS1='\[\e[1;32m\]\u@webvm\[\e[m\]:\[\e[1;34m\]\w\[\e[m\]\$ '

# Aliases
alias ls='ls -hF --color=auto'
alias l='ls -lhF --color=auto'
alias ll='ls -lahF --color=auto'
alias la='ls -A'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Enable programmable completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
