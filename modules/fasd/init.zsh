source ${0:h}/external/fasd --init env || return 1

local fasd_cache="${0:h}/cache.zsh"
if [[ ! -e ${fasd_cache} ]]; then
  fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install > ${fasd_cache}
fi
source ${fasd_cache} || return 1

alias v='f -e vim -b viminfo'
