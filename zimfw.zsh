# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

if (( ! # )); then

# Stage 1 of sourcing this script
autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print -u2 "init: error starting Zim: You're using Zsh version ${ZSH_VERSION} and versions < 5.2 are not supported. Update your Zsh."
  return 1
fi

# Define Zim location
: ${ZIM_HOME=${0:h}}

# Source user configuration
[[ -f ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc

# Set input mode before loading modules
if zstyle -t ':zim:input' mode 'vi'; then
  bindkey -v
else
  bindkey -e
fi

# Autoload enabled modules' functions
() {
  local zfunction
  local -a zmodules
  zstyle -a ':zim' modules 'zmodules'

  setopt LOCAL_OPTIONS EXTENDED_GLOB
  fpath=(${ZIM_HOME}/modules/${^zmodules}/functions(/FN) ${fpath})
  for zfunction in ${ZIM_HOME}/modules/${^zmodules}/functions/^(_*|*.*|prompt_*_setup)(-.N:t); do
    autoload -Uz ${zfunction}
  done
}

# Source enabled modules' init scripts
() {
  local zmodule zdir zfile
  local -a zmodules
  zstyle -a ':zim' modules 'zmodules'

  for zmodule in ${zmodules}; do
    zdir=${ZIM_HOME}/modules/${zmodule}
    if [[ ! -d ${zdir} ]]; then
      print -u2 "init: module ${zmodule} not installed"
    else
      for zfile in ${zdir}/{init.zsh,${zmodule}.{zsh,plugin.zsh,zsh-theme,sh}}; do
        if [[ -f ${zfile} ]]; then
          source ${zfile}
          break
        fi
      done
    fi
  done
}

_zimfw_compile() {
  setopt LOCAL_OPTIONS EXTENDED_GLOB
  autoload -U zrecompile

  local zdir zfile
  local -a zmodules
  zstyle -a ':zim' modules 'zmodules'

  # Compile the completion cache; significant speedup
  local zdumpfile
  zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile="${ZDOTDIR:-${HOME}}/.zcompdump"
  if [[ -f ${zdumpfile} ]]; then
    zrecompile -p ${1} ${zdumpfile} || return 1
  fi

  # Compile .zshrc
  zrecompile -p ${1} ${ZDOTDIR:-${HOME}}/.zshrc || return 1

  # Compile enabled modules' autoloaded functions
  for zdir in ${ZIM_HOME}/modules/${^zmodules}/functions(/FN); do
    zrecompile -p ${1} ${zdir}.zwc ${zdir}/^(_*|*.*|prompt_*_setup)(-.N) || return 1
  done

  # Compile enabled modules' scripts
  for zfile in ${ZIM_HOME}/modules/${^zmodules}/(^*test*/)#*.zsh{,-theme}(.NLk+1); do
    zrecompile -p ${1} ${zfile} || return 1
  done

  # Compile this script
  zrecompile -p ${1} ${ZIM_HOME}/zimfw.zsh || return 1

  if [[ ${1} != -q ]]; then
    print -P '%F{green}✓%f Done with compile.'
  fi
}

zimfw() {
  case ${1} in
    compile|login-init) _zimfw_compile ${2} ;;
    *)
      source ${ZIM_HOME}/zimfw.zsh 2
      zimfw "${@}"
      ;;
  esac
}
# Stage 1 done

elif [[ ${1} == 2 ]]; then

# Stage 2 of sourcing this script. Should only be done internally by zimfw.
_zimfw_modules() {
  local zmodule zurl ztype zrev
  local -a zmodules
  local -A zoptions
  zstyle -a ':zim' modules 'zmodules'
  for zmodule in ${zmodules}; do
    zstyle -a ':zim:module' ${zmodule} 'zoptions'
    [[ ${zoptions[frozen]} == yes ]] && continue
    zurl=${zoptions[url]:-${zmodule}}
    if [[ ${zurl} != /* && ${zurl} != *@*:* ]]; then
      # Count number of slashes
      case ${#zurl//[^\/]/} in
        0) zurl="https://github.com/zimfw/${zurl}.git" ;;
        1) zurl="https://github.com/${zurl}.git" ;;
      esac
    fi
    if [[ -n ${zoptions[tag]} ]]; then
      ztype=tag
      zrev=${zoptions[tag]}
    else
      ztype=branch
      zrev=${zoptions[branch]:-master}
    fi
    # Cannot have an empty space at the EOL because this is read by xargs -L1
    print "'${ZIM_HOME}/modules/${zmodule}' '${zurl}' '${ztype}' '${zrev}'${1:+ ${1}}"
  done
}

_zimfw_clean_modules() {
  local zdir zmodule
  local -a zmodules
  local -A zoptions
  # Source .zimrc to refresh zmodules
  [[ -f ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc
  zstyle -a ':zim' modules 'zmodules'
  for zdir in ${ZIM_HOME}/modules/*(/N); do
    zmodule=${zdir:t}
    # If zmodules does not contain the zmodule
    if (( ! ${zmodules[(I)${zmodule}]} )); then
      zstyle -a ':zim:module' ${zmodule} 'zoptions'
      [[ ${zoptions[frozen]} == yes ]] && continue
      command rm -rf ${zdir} || return 1
      [[ ${1} != -q ]] && print ${zdir}
    fi
  done
  if [[ ${1} != -q ]]; then
    print -P "%F{green}✓%f Done with clean-modules."
  fi
}

_zimfw_clean_compiled() {
  setopt LOCAL_OPTIONS PIPE_FAIL
  local find_opt rm_opt
  if [[ ${1} != -q ]]; then
    find_opt='-print'
    rm_opt='-v'
  fi
  command find ${ZIM_HOME} \( -name '*.zwc' -o -name '*.zwc.old' \) -delete ${find_opt} || return 1
  command rm -f ${rm_opt} ${ZDOTDIR:-${HOME}}/.zshrc.zwc{,.old} || return 1
  if [[ ${1} != -q ]]; then
    print -P "%F{green}✓%f Done with clean-compiled. Run %Bzimfw compile%b to re-compile."
  fi
}

_zimfw_clean_dumpfile() {
  setopt LOCAL_OPTIONS PIPE_FAIL
  local zdumpfile zout zopt
  zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile="${ZDOTDIR:-${HOME}}/.zcompdump"
  [[ ${1} != -q ]] && zopt='-v'
  command rm -f ${zopt} ${zdumpfile}{,.zwc{,.old}} || return 1
  if [[ ${1} != -q ]]; then
    print -P "%F{green}✓%f Done with clean-dumpfile. Restart your terminal to dump an updated configuration."
  fi
}

_zimfw_info() {
  print 'Zim version:  1.0.0-SNAPSHOT (previous commit is 601941f)'
  print "Zsh version:  ${ZSH_VERSION}"
  print "System info:  $(command uname -a)"
}

_zimfw_upgrade() {
  local zscript=${ZIM_HOME}/zimfw.zsh
  local zurl=https://raw.githubusercontent.com/zimfw/zimfw/develop/zimfw.zsh
  if (( ${+commands[wget]} )); then
    command wget -nv ${1} -O ${zscript}.new ${zurl} || return 1
  else
    command curl -fsSL -o ${zscript}.new ${zurl} || return 1
  fi
  if command cmp -s ${zscript}{,.new}; then
    command rm ${zscript}.new && \
        if [[ ${1} != -q ]]; then
          print -P "%F{green}✓%f zimfw.zsh: Already up to date."
        fi
  else
    command mv ${zscript}{,.old} && command mv ${zscript}{.new,} && \
        if [[ ${1} != -q ]]; then
          print -P "%F{green}✓%f zimfw.zsh: upgraded. Restart your terminal for changes to take effect."
        fi
  fi
}

unfunction zimfw
zimfw() {
  local zusage="usage: ${0} <action> [-q]
actions:
  clean            Clean all (see below).
  clean-modules    Clean unused modules.
  clean-compiled   Clean Zsh compiled files.
  clean-dumpfile   Clean completion dump file.
  compile          Compile Zsh files.
  info             Print Zim and system info.
  install          Install new modules.
  update           Update current modules.
  upgrade          Upgrade Zim.
options:
  -q               Quiet, only outputs errors."

  if [[ ${#} -ne 1 && ${2} != -q ]]; then
    print -u2 ${zusage}
    return 1
  fi

  local ztool
  case ${1} in
    install)
      ztool="# This runs in a new shell
DIR=\${1}
URL=\${2}
REV=\${4}
OPT=\${5}
MODULE=\${DIR:t}
CLEAR_LINE=\"\033[2K\r\"
if [[ -e \${DIR} ]]; then
  # Already exists
  return 0
fi
[[ \${OPT} != -q ]] && print -n \"\${CLEAR_LINE}Installing \${MODULE} …\"
if ERR=\$(command git clone -b \${REV} -q --recursive \${URL} \${DIR} 2>&1); then
  if [[ \${OPT} != -q ]]; then
    print -P \"\${CLEAR_LINE}%F{green}✓%f \${MODULE}: Installed\"
  fi
else
  print -P \"\${CLEAR_LINE}%F{red}✗ \${MODULE}: Error%f\n\${ERR}\"
  return 1
fi
"
      ;;
    update)
      ztool="# This runs in a new shell
DIR=\${1}
URL=\${2}
TYPE=\${3}
REV=\${4}
OPT=\${5}
MODULE=\${DIR:t}
CLEAR_LINE=\"\033[2K\r\"
[[ \${OPT} != -q ]] && print -n \"\${CLEAR_LINE}Updating \${MODULE} …\"
if ! cd \${DIR} 2>/dev/null; then
  print -P \"\${CLEAR_LINE}%F{red}✗ \${MODULE}: Not installed%f\"
  return 1
fi
if [[ \${PWD} != \$(command git rev-parse --show-toplevel 2>/dev/null) ]]; then
  # Not in repo root. Will not try to update.
  return 0
fi
if [[ \${URL} != \$(command git config --get remote.origin.url) ]]; then
  print -P \"\${CLEAR_LINE}%F{red}✗ \${MODULE}: URL does not match. Expected \${URL}. Will not try to update.%f\"
  return 1
fi
if [[ \${TYPE} == tag ]]; then
  if [[ \${REV} == \$(command git describe --tags --exact-match 2>/dev/null) ]]; then
    [[ \${OPT} != -q ]] && print -P \"\${CLEAR_LINE}%F{green}✓%f \${MODULE}: Already up to date\"
    return 0
  fi
fi
if ! ERR=\$(command git fetch -pq origin \${REV} 2>&1); then
  print -P \"\${CLEAR_LINE}%F{red}✗ \${MODULE}: Error (1)%f\n\${ERR}\"
  return 1
fi
if [[ \${TYPE} == branch ]]; then
  LOG_REV=\"\${REV}@{u}\"
else
  LOG_REV=\${REV}
fi
LOG=\$(command git log --graph --color --format='%C(yellow)%h%C(reset) %s %C(cyan)(%cr)%C(reset)' ..\${LOG_REV} 2>/dev/null)
if ! ERR=\$(command git checkout -q \${REV} -- 2>&1); then
  print -P \"\${CLEAR_LINE}%F{red}✗ \${MODULE}: Error (2)%f\n\${ERR}\"
  return 1
fi
if [[ \${TYPE} == branch ]]; then
  if ! OUT=\$(command git merge --ff-only --no-progress -n 2>&1); then
    print -P \"\${CLEAR_LINE}%F{red}✗ \${MODULE}: Error (3)%f\n\${OUT}\"
    return 1
  fi
  # keep just first line of OUT
  OUT=\${OUT%%($'\n'|$'\r')*}
else
  OUT=\"Updating to \${TYPE} \${REV}\"
fi
if [[ -n \${LOG} ]]; then
  LOG_LINES=('  '\${(f)^LOG})
  OUT=\"\${OUT}
\${(F)LOG_LINES}\"
fi
if ERR=\$(command git submodule update --init --recursive -q 2>&1); then
  if [[ \${OPT} != -q ]]; then
    print -R \"\$(print -P \"\${CLEAR_LINE}%F{green}✓%f\") \${MODULE}: \${OUT}\"
  fi
else
  print -P \"\${CLEAR_LINE}%F{red}✗ \${MODULE}: Error (4)%f\n\${ERR}\"
  return 1
fi
"
      ;;
  esac

  case ${1} in
    clean)
      _zimfw_clean_modules ${2} && \
          _zimfw_clean_compiled ${2} && \
          _zimfw_clean_dumpfile ${2}
      ;;
    clean-modules) _zimfw_clean_modules ${2} ;;
    clean-compiled) _zimfw_clean_compiled ${2} ;;
    clean-dumpfile) _zimfw_clean_dumpfile ${2} ;;
    compile|login-init) _zimfw_compile ${2} ;;
    info) _zimfw_info ${2} ;;
    install|update)
      # Source .zimrc to refresh zmodules
      [[ -f ${ZDOTDIR:-${HOME}}/.zimrc ]] && source ${ZDOTDIR:-${HOME}}/.zimrc
      _zimfw_modules ${2} | xargs -L1 -P10 zsh -c ${ztool} ${1} && \
          if [[ ${2} != -q ]]; then
            print -P "%F{green}✓%f Done with ${1}. Restart your terminal for any changes to take effect."
          fi
      ;;
    upgrade) _zimfw_upgrade ${2} ;;
    *)
      print -u2 ${zusage}
      return 1
      ;;
  esac
}
# Stage 2 done

fi
