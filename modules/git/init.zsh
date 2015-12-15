#
# git aliases and functions
#

if (( ! $+commands[git] )); then
  return 1
fi

source "${0:h}/alias.zsh"
