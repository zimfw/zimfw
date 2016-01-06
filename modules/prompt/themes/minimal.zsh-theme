#
# Minimal theme
# https://github.com/S1cK94/minimal
#

function minimal_user() {
  echo "%(!.$on_color.$off_color)$prompt_char%f"
}

function minimal_jobs() {
  echo "%(1j.$on_color.$off_color)$prompt_char%f"
}

function minimal_vimode(){
  local ret=""

  case $KEYMAP in
    main|viins)
      ret+="$on_color"
      ;;
    vicmd)
      ret+="$off_color"
      ;;
  esac

  ret+="$prompt_char%f"

  echo "$ret"
}

function minimal_status() {
  echo "%(0?.$on_color.$err_color)$prompt_char%f"
}

function -prompt_ellipse(){
  local string=$1
  local sep="$rsc..$path_color"
  if [[ $MINIMAL_SHORTEN == true ]] && [[ ${#string} -gt 10 ]]; then
    echo "${string:0:4}$sep${string: -4}"
  else
    echo $string
  fi
}

function minimal_path() {
  local path_color="%F{244}"
  local rsc="%f"
  local sep="$rsc/$path_color"

  echo "$path_color$(sed s_/_${sep}_g <<< $(short_pwd))$rsc"
}

function git_branch_name() {
  local branch_name="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
  [[ -n $branch_name ]] && echo "$branch_name"
}

function git_repo_status(){
  local rs="$(git status --porcelain -b)"

  if $(echo "$rs" | grep -v '^##' &> /dev/null); then # is dirty
    echo "%F{red}"
  elif $(echo "$rs" | grep '^## .*diverged' &> /dev/null); then # has diverged
    echo "%F{red}"
  elif $(echo "$rs" | grep '^## .*behind' &> /dev/null); then # is behind
    echo "%F{11}"
  elif $(echo "$rs" | grep '^## .*ahead' &> /dev/null); then # is ahead
    echo "%f"
  else # is clean
    echo "%F{green}"
  fi
}

function minimal_git() {
  local bname=$(git_branch_name)
  if [[ -n $bname ]]; then
    local infos="$(git_repo_status)$bname%f"
    echo " $infos"
  fi
}

function zle-line-init zle-line-finish zle-keymap-select {
  zle reset-prompt
  zle -R
}

function prompt_minimal_precmd() {
  zle -N zle-line-init
  zle -N zle-keymap-select
  zle -N zle-line-finish

  PROMPT='$(minimal_user)$(minimal_jobs)$(minimal_vimode)$(minimal_status) '
  RPROMPT='$(minimal_path)$(minimal_git)'
}

function prompt_minimal_setup() {
  prompt_char="❯"
  on_color="%F{green}"
  off_color="%f"
  err_color="%F{red}"

  autoload -Uz add-zsh-hook

  add-zsh-hook precmd prompt_minimal_precmd
  prompt_opts=(cr subst percent)
}

prompt_minimal_setup "$@"
