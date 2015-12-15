#
# utility functions and options
#


#
# general aliases
#

alias chmod='chmod --preserve-root -v'
alias chown='chown --preserve-root -v'
alias df='df -kh'
alias du='du -kh'


#
# ls
#

if [[ dircolors ]]; then
  if [[ -s ${HOME}/.dir_colors ]]; then
    eval "$(dircolors --sh ${HOME}/.dir_colors)"
  else
    eval "$(dircolors --sh)"
  fi

  alias ls='ls --group-directories-first --color=auto'
  
else
  export LSCOLORS='exfxcxdxbxGxDxabagacad'
  export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'

  alias ls='ls --group-directories-first -G'
fi

alias l='ls -lAh'        # one column, all files, human-readable sizes
