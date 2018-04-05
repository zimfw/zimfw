#
# Utility Functions and Options
#

#
# Colours
#

if (( terminfo[colors] >= 8 )); then

  # ls Colours
  # GNU colours are used by completion module for all OSTYPEs
  (( ! ${+LS_COLORS} )) && export LS_COLORS='di=1;34:ln=35:so=32:pi=33:ex=31:bd=1;36:cd=1;33:su=30;41:sg=30;46:tw=30;42:ow=30;43'

  if (( ${+commands[dircolors]} )); then
    # GNU

    [[ -s ${HOME}/.dir_colors ]] && eval "$(dircolors --sh ${HOME}/.dir_colors)"

    alias ls='ls --group-directories-first --color=auto'

  else
    # BSD

    (( ! ${+LSCOLORS} )) && export LSCOLORS='ExfxcxdxbxGxDxabagacad'

    # stock OpenBSD ls does not support colors at all, but colorls does.
    if [[ ${OSTYPE} == openbsd* ]]; then
      if (( ${+commands[colorls]} )); then
        alias ls='colorls -G'
      fi
    else
      alias ls='ls -G'
    fi
  fi

  # grep Colours
  (( ! ${+GREP_COLOR} )) && export GREP_COLOR='37;45'               #BSD
  (( ! ${+GREP_COLORS} )) && export GREP_COLORS="mt=${GREP_COLOR}"  #GNU
  if [[ ${OSTYPE} == openbsd* ]]; then
    if (( ${+commands[ggrep]} )); then
      alias grep='ggrep --color=auto'
    fi
  else
   alias grep='grep --color=auto'
  fi

  # less Colours
  if [[ ${PAGER} == 'less' ]]; then
    (( ! ${+LESS_TERMCAP_mb} )) && export LESS_TERMCAP_mb=$'\E[1;31m'   # Begins blinking.
    (( ! ${+LESS_TERMCAP_md} )) && export LESS_TERMCAP_md=$'\E[1;31m'   # Begins bold.
    (( ! ${+LESS_TERMCAP_me} )) && export LESS_TERMCAP_me=$'\E[0m'      # Ends mode.
    (( ! ${+LESS_TERMCAP_se} )) && export LESS_TERMCAP_se=$'\E[0m'      # Ends standout-mode.
    (( ! ${+LESS_TERMCAP_so} )) && export LESS_TERMCAP_so=$'\E[7m'      # Begins standout-mode.
    (( ! ${+LESS_TERMCAP_ue} )) && export LESS_TERMCAP_ue=$'\E[0m'      # Ends underline.
    (( ! ${+LESS_TERMCAP_us} )) && export LESS_TERMCAP_us=$'\E[1;32m'   # Begins underline.
  fi
fi


#
# ls Aliases
#

alias l='ls -lAh'         # all files, human-readable sizes
[[ -n ${PAGER} ]] && alias lm="l | ${PAGER}" # all files, human-readable sizes, use pager
alias ll='ls -lh'         # human-readable sizes
alias lr='ll -R'          # human-readable sizes, recursive
alias lx='ll -XB'         # human-readable sizes, sort by extension (GNU only)
alias lk='ll -Sr'         # human-readable sizes, largest last
alias lt='ll -tr'         # human-readable sizes, most recent last
alias lc='lt -c'          # human-readable sizes, most recent last, change time


#
# File Downloads
#

# order of preference: aria2c, axel, wget, curl. This order is derrived from speed based on personal tests.
if (( ${+commands[aria2c]} )); then
  alias get='aria2c --max-connection-per-server=5 --continue'
elif (( ${+commands[axel]} )); then
  alias get='axel --num-connections=5 --alternate'
elif (( ${+commands[wget]} )); then
  alias get='wget --continue --progress=bar --timestamping'
elif (( ${+commands[curl]} )); then
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
fi


#
# Resource Usage
#

alias df='df -kh'
alias du='du -kh'


#
# Always wear a condom
#

if [[ ${OSTYPE} == linux* ]]; then
  alias chmod='chmod --preserve-root -v'
  alias chown='chown --preserve-root -v'
fi

# not aliasing rm -i, but if safe-rm is available, use condom.
# if safe-rmdir is available, the OS is suse which has its own terrible 'safe-rm' which is not what we want
if (( ${+commands[safe-rm]} && ! ${+commands[safe-rmdir]} )); then
  alias rm='safe-rm'
fi
