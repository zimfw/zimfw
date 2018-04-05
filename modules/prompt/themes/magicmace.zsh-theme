# vim:et sts=2 sw=2 ft=zsh
#
# magicmace theme
# Ideas and code taken from:
#   xero's zsh prompt <http://code.xero.nu/dotfiles>
#   eriner's eriner prompt <https://github.com/zimfw/zimfw/blob/master/modules/prompt/themes/eriner.zsh-theme>
#
# Requires the `git-info` zmodule to be included in the .zimrc file.

# Global variables
function {
  COLOR_ROOT="%F{red}"
  COLOR_USER="%F{cyan}"
  COLOR_NORMAL="%F{white}"
  COLOR_ERROR="%F{red}"

  if (( ${EUID} )); then
    COLOR_USER_LEVEL=${COLOR_USER}
  else
    COLOR_USER_LEVEL=${COLOR_ROOT}
  fi
}

# Status:
# - was there an error?
# - are there background jobs?
# - are we in a ranger session?
prompt_magicmace_status() {
  local symbols=""

  (( ${RETVAL} )) && symbols+="${COLOR_ERROR}${RETVAL}${COLOR_NORMAL}" # $? for error.
  (( $(jobs -l | wc -l) > 0 )) && symbols+='b' # 'b' for background.
  (( ${RANGER_LEVEL} )) && symbols+='r' # 'r' for... you guessed it!

  [[ -n ${symbols} ]] && print -n "─${COLOR_NORMAL}${symbols}${COLOR_USER_LEVEL}─"
}

prompt_magicmace_git() {
  [[ -n ${git_info} ]] && print -n "${(e)git_info[prompt]}"
}

prompt_magicmace_precmd() {
  # While it would be apt to have this as a local variable in prompt_status(),
  # $? (returned value) and ${(%):-%?} ("The return status of the last command
  # executed just before the prompt") both change before executing the function.
  # Is this perhaps because prompt_status _is_ here?
  # We could also just set $? as an argument, and thus get our nifty local variable,
  # but that's stretching it, and makes the code harder to read.
  RETVAL=$?
  (( ${+functions[git-info]} )) && git-info
}

prompt_magicmace_setup() {
  autoload -Uz add-zsh-hook && add-zsh-hook precmd prompt_magicmace_precmd
  autoload -Uz colors && colors

  prompt_opts=(cr percent sp subst)

  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c...'
  zstyle ':zim:git-info:dirty' format '*'
  zstyle ':zim:git-info:ahead' format '↑'
  zstyle ':zim:git-info:behind' format '↓'
  zstyle ':zim:git-info:keys' format \
    'prompt' '─[${COLOR_NORMAL}%b%c%D%A%B${COLOR_USER_LEVEL}]'

  # Call git directly, ignoring aliases under the same name.
  PS1='${COLOR_USER_LEVEL}$(prompt_magicmace_status)[${COLOR_NORMAL}$(short_pwd)${COLOR_USER_LEVEL}]$(prompt_magicmace_git)── ─%f '
  RPS1=''
}

prompt_magicmace_setup "${@}"
