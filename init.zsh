#
# Zim initializition
#

autoload -Uz is-at-least
if ! is-at-least 5.2; then
  print "ERROR: Zim didn't start. You're using zsh version ${ZSH_VERSION}, and versions < 5.2 are not supported. Update your zsh." >&2
  return 1
fi

# Define zim location
(( ! ${+ZIM_DATA_DIR} )) && \
  if [[ -d "${XDG_DATA_HOME:-"${HOME}/.local/share"}/zim" ]]; then
    export ZIM_DATA_DIR="${XDG_DATA_HOME:-"${HOME}/.local/share"}/zim"
  elif [[ -d "${ZDOTDIR:-${HOME}}/.zim" ]]; then
    export ZIM_DATA_DIR="${ZDOTDIR:-${HOME}}/.zim"
  else
    export ZIM_DATA_DIR="${XDG_DATA_HOME:-"${HOME}/.local/share"}/zim"
  fi

# Source user configuration
if [[ -s "${ZDOTDIR:-${HOME}}/.zimrc" ]]; then
  source "${ZDOTDIR:-${HOME}}/.zimrc"
fi

load_zim_module() {
  local wanted_module

  for wanted_module (${zmodules}); do
    if [[ -s "${ZIM_DATA_DIR}/modules/${wanted_module}/init.zsh" ]]; then
      source "${ZIM_DATA_DIR}/modules/${wanted_module}/init.zsh"
    elif [[ ! -d "${ZIM_DATA_DIR}/modules/${wanted_module}" ]]; then
      print "No such module \"${wanted_module}\"." >&2
    fi
  done
}

load_zim_function() {
  local function_glob='^([_.]*|prompt_*_setup|README*)(-.N:t)'
  local mod_function

  # autoload searches fpath for function locations; add enabled module function paths
  fpath=(${${zmodules}:+${ZIM_DATA_DIR}/modules/${^zmodules}/functions(/FN)} ${fpath})

  function {
    setopt LOCAL_OPTIONS EXTENDED_GLOB

    for mod_function in ${ZIM_DATA_DIR}/modules/${^zmodules}/functions/${~function_glob}; do
      autoload -Uz ${mod_function}
    done
  }
}

# initialize zim modules
load_zim_function
load_zim_module

unset zmodules
unfunction load_zim_{module,function}
