#
# magicmace theme
# Ideas and code taken from:
#   xero's zsh prompt <http://code.xero.nu/dotfiles>
#   eriner's eriner prompt <https://github.com/Eriner/zim/blob/master/modules/prompt/themes/eriner.zsh-theme>
#

# Global variables
function {
  COLOR_ROOT="%F{red}"
  COLOR_USER="%F{cyan}"
  COLOR_NORMAL="%F{white}"
  COLOR_ERROR="%F{red}"

  if [[ "$EUID" -ne "0" ]]; then
    USER_LEVEL="${COLOR_USER}"
  else
    USER_LEVEL="${COLOR_ROOT}"
  fi
}

# Status:
# - was there an error?
# - are there background jobs?
# - are we in a ranger session?
prompt_status() {
  local symbols=""

  [[ ${RETVAL} -ne 0 ]]          && symbols+='${COLOR_ERROR}${RETVAL}${COLOR_NORMAL}'  # 'e' for error.
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+='b' # 'b' for background.
  [[ ${RANGER_LEVEL} -ne 0 ]]    && symbols+='r' # 'r' for... you guessed it!

  [[ -n ${symbols} ]] && print -Pn "─${COLOR_NORMAL}${symbols}${COLOR_USER}─"
}

prompt_git() {
  local ico_dirty='*'
  local ico_ahead='🠙'
  local ico_behind='🠛'
  local ico_diverged='⥮'
  local git_info=""

  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules)"
  }

  vcs_info
  git_info=${vcs_info_msg_0_} # branch name
  if [[ -n ${git_info} ]]; then

    if is_dirty; then
      git_info+=${ico_dirty}
    fi

    stat=$(git status 2> /dev/null | command sed -n 2p)
    case "${stat}" in
      *ahead*)    git_info+=${ico_ahead}    ;;
      *behind*)   git_info+=${ico_behind}   ;;
      *diverged*) git_info+=${ico_diverged} ;;
      *);;
    esac

    print -Pn \
    "${USER_LEVEL}─[${COLOR_NORMAL}${git_info}${USER_LEVEL}]"
  fi
}

prompt_magicmace_precmd() {
  # While it would be apt to have this as a local variable in prompt_status(),
  # $? (returned value) and ${(%):-%?} ("The return status of the last command
  # executed just before the prompt") both change before executing the function.
  # Is this perhaps because prompt_status _is_ here?
  # We could also just set $? as an argument, and thus get our nifty local variable,
  # but that's stretching it, and makes the code harder to read.
  RETVAL=$?

  PROMPT='${USER_LEVEL}$(prompt_status)[${COLOR_NORMAL}$(short_pwd)${USER_LEVEL}]$(prompt_git)── -%f '
}

prompt_magicmace_setup() {
  autoload -Uz colors && colors
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst percent)

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:*' use-simple true
  # Only export branch name, as that is the only data we need.
  zstyle ':vcs_info:*' max-exports 1
  zstyle ':vcs_info:git*' formats '%b'

  # Call git directly, ignoring aliases under the same name.
  zstyle ':vcs_info:git:*:-all-' command =git

  add-zsh-hook precmd prompt_magicmace_precmd
}

prompt_magicmace_setup "$@"
