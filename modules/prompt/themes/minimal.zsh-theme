#
# Minimal theme
# https://github.com/S1cK94/minimal
#
# Requires the `git-info` zmodule to be included in the .zimrc file.

# Global variables
function {
  PROMPT_CHAR='❯'

  ON_COLOR='%F{green}'
  OFF_COLOR='%f'
  ERR_COLOR='%F{red}'
}

prompt_minimal_user() {
  print -n '%(!.${ON_COLOR}.${OFF_COLOR})${PROMPT_CHAR}'
}

prompt_minimal_jobs() {
  print -n '%(1j.${ON_COLOR}.${OFF_COLOR})${PROMPT_CHAR}'
}

prompt_minimal_vimode() {
  local color

  case ${KEYMAP} in
    main|viins)
      color=${ON_COLOR}
      ;;
    *)
      color=${OFF_COLOR}
      ;;
  esac

  print -n "${color}${PROMPT_CHAR}"
}

prompt_minimal_status() {
  print -n '%(0?.${ON_COLOR}.${ERR_COLOR})${PROMPT_CHAR}'
}

prompt_minimal_path() {
  local path_color='%F{244}'
  print -n "${path_color}${$(short_pwd)//\//%f\/${path_color}}%f"
}

prompt_minimal_git() {
  if [[ -n ${git_info} ]]; then
    print -n " ${(e)git_info[color]}${(e)git_info[prompt]}"
  fi
}

function zle-line-init zle-keymap-select {
  zle reset-prompt
  zle -R
}

prompt_minimal_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_minimal_setup() {
  zle -N zle-line-init
  zle -N zle-keymap-select

  autoload -Uz colors && colors
  autoload -Uz add-zsh-hook

  prompt_opts=(cr percent sp subst)

  add-zsh-hook precmd prompt_minimal_precmd

  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:dirty' format '${ERR_COLOR}'
  zstyle ':zim:git-info:diverged' format '${ERR_COLOR}'
  zstyle ':zim:git-info:behind' format '%F{11}'
  zstyle ':zim:git-info:ahead' format '${OFF_COLOR}'
  zstyle ':zim:git-info:keys' format \
    'prompt' '%b%c' \
    'color' '$(coalesce "%D" "%V" "%B" "%A" "${ON_COLOR}")'

  PROMPT="$(prompt_minimal_user)$(prompt_minimal_jobs)\$(prompt_minimal_vimode)$(prompt_minimal_status)%f "
  RPROMPT='$(prompt_minimal_path)$(prompt_minimal_git)'
}

prompt_minimal_setup "$@"
