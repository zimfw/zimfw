#
# Zim initializition
#

autoload -Uz is-at-least
if ! is-at-least 5.2; then
  print "ERROR: Zim didn't start. You're using zsh version ${ZSH_VERSION}, and versions < 5.2 are not supported. Update your zsh." >&2
  return 1
fi

# Define zim location
(( ! ${+ZIM_HOME} )) && export ZIM_HOME="${ZDOTDIR:-${HOME}}/.zim"

# Source user configuration
if [[ -s "${ZDOTDIR:-${HOME}}/.zimrc" ]]; then
  source "${ZDOTDIR:-${HOME}}/.zimrc"
fi

load_zim_module() {
  local wanted_module

  for wanted_module (${zmodules}); do
    if [[ -s "${ZIM_HOME}/modules/${wanted_module}/init.zsh" ]]; then
      source "${ZIM_HOME}/modules/${wanted_module}/init.zsh"
    elif [[ ! -d "${ZIM_HOME}/modules/${wanted_module}" ]]; then
      print "No such module \"${wanted_module}\"." >&2
    fi
  done
}

load_zim_function() {
  local function_glob='^([_.]*|prompt_*_setup|README*)(-.N:t)'
  local mod_function

  # autoload searches fpath for function locations; add enabled module function paths
  fpath=(${ZIM_HOME}/functions.zwc ${ZIM_HOME}/modules/prompt/functions ${fpath})

  function {
    setopt LOCAL_OPTIONS EXTENDED_GLOB

    for mod_function in ${ZIM_HOME}/modules/${^zmodules}/functions/${~function_glob}; do
      autoload -Uz ${mod_function}
    done
  }
}

# initialize zim modules
load_zim_function
load_zim_module

unset zmodules
unfunction load_zim_{module,function}
