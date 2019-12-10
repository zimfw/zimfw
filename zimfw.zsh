# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

# MIT License
#
# Copyright (c) 2015-2016 Matt Hamilton and contributors
# Copyright (c) 2016-2019 Eric Nielsen, Matt Hamilton and contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

autoload -Uz is-at-least && if ! is-at-least 5.2; then
  print -u2 -R "${0}: Error starting Zim. You're using Zsh version ${ZSH_VERSION} and versions < 5.2 are not supported. Update your Zsh."
  return 1
fi

# Define Zim location
: ${ZIM_HOME=${0:A:h}}

_zimfw_compile() {
  setopt LOCAL_OPTIONS EXTENDED_GLOB
  autoload -U zrecompile
  local zdumpfile zdir zfile

  # Compile the completion cache; significant speedup
  zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile="${ZDOTDIR:-${HOME}}/.zcompdump"
  if [[ -f ${zdumpfile} ]]; then
    zrecompile -p ${1} ${zdumpfile} || return 1
  fi

  # Compile .zshrc
  zrecompile -p ${1} ${ZDOTDIR:-${HOME}}/.zshrc || return 1

  # Compile autoloaded functions
  for zdir in ${fpath}; do
    [[ ${zdir} == (.|..) || ${zdir} == (.|..)/* ]] && continue
    zfile=(${zdir}/^(*.*)(N-.))
    if [[ -w ${zdir:h} && -n ${zfile} ]]; then
      zrecompile -p ${1} ${zdir}.zwc ${zfile} || return 1
    fi
  done

  # Compile scripts
  for zfile in ${ZIM_HOME}/(^*test*/)#*.zsh{,-theme}(N-.); do
    zrecompile -p ${1} ${zfile} || return 1
  done

  if [[ ${1} != -q ]]; then
    print -P '%F{green}✓%f Done with compile.'
  fi
}

if [[ ${1} == (compile|login-init) && ${2} == (|-q) ]]; then
  _zimfw_compile ${2}
  return
fi

_zimfw_build() {
  () {
    local -r ztarget=${ZIM_HOME}/init.zsh
    if [[ ${ztarget} -nt ${ZDOTDIR:-${HOME}}/.zimrc ]] && command cmp -s ${ztarget} ${1}; then
      if (( ! _zquiet )); then
        print -PR "%F{green}✓%f %B${ztarget}:%b Already up to date"
      fi
    else
      if [[ -e ${ztarget} ]]; then
        command mv -f ${ztarget}{,.old} || return 1
      fi
      command mv -f ${1} ${ztarget} && \
          if (( ! _zquiet )); then
            print -PR "%F{green}✓%f %B${ztarget}:%b Updated. Restart your terminal for changes to take effect."
          fi
    fi
    if (( ! _zquiet )); then
      print -P '%F{green}✓%f Done with build.'
    fi
  } =(
    print -R "zimfw() { source ${ZIM_HOME}/zimfw.zsh \"\${@}\" }"
    (( ${#_zfpaths} )) && print -R 'fpath=('${_zfpaths:P}' ${fpath})'
    (( ${#_zfunctions} )) && print -R 'autoload -Uz '${_zfunctions}
    print -Rn ${(F):-source ${^_zscripts:P}}
  )
}

zmodule() {
  local -r zusage="
Usage: %B${0}%b <url> [%B-n%b|%B--name%b <module_name>] [options]

Repository options:
  %B-b%b|%B--branch%b <branch_name>  Use specified branch when installing and updating the module
  %B-t%b|%B--tag%b <tag_name>        Use specified tag when installing and updating the module
  %B-z%b|%B--frozen%b                Don't install or update the module

Startup options:
  %B-f%b|%B--fpath%b <path>              Add specified path to fpath
  %B-a%b|%B--autoload%b <function_name>  Autoload specified function
  %B-s%b|%B--source%b <file_path>        Source specified file
  %B-d%b|%B--disabled%b                  Don't use or clean the module
"
  if [[ ${${funcfiletrace[1]%:*}:t} != .zimrc ]]; then
    print -u2 -PR "%F{red}${0}: Must be called from ${ZDOTDIR:-${HOME}}/.zimrc%f"$'\n'${zusage}
    return 1
  fi
  if (( ! # )); then
    print -u2 -PR "%F{red}✗ ${funcfiletrace[1]}: Missing zmodule url%f"
    _zfailed=1
    return 1
  fi
  setopt LOCAL_OPTIONS EXTENDED_GLOB
  local zmodule=${1:t} zurl=${1}
  local ztype=branch zrev=master
  local -i zdisabled=0 zfrozen=0
  local -a zfpaths zfunctions zscripts
  local zarg
  if [[ ${zurl} =~ ^[^:/]+: ]]; then
    zmodule=${zmodule%.git}
  elif [[ ${zurl} != /* ]]; then
    # Count number of slashes
    case ${#zurl//[^\/]/} in
      0) zurl="https://github.com/zimfw/${zurl}.git" ;;
      1) zurl="https://github.com/${zurl}.git" ;;
    esac
  fi
  shift
  if [[ ${1} == (-n|--name) ]]; then
    if (( # < 2 )); then
      print -u2 -PR "%F{red}✗ ${funcfiletrace[1]}:%B${zmodule}:%b Missing argument for zmodule option ${1}%f"
      _zfailed=1
      return 1
    fi
    shift
    zmodule=${1}
    shift
  fi
  local -r zdir=${ZIM_HOME}/modules/${zmodule}
  while (( # > 0 )); do
    case ${1} in
      -b|--branch|-t|--tag|-f|--fpath|-a|--autoload|-s|--source)
        if (( # < 2 )); then
          print -u2 -PR "%F{red}✗ ${funcfiletrace[1]}:%B${zmodule}:%b Missing argument for zmodule option ${1}%f"
          _zfailed=1
          return 1
        fi
        ;;
    esac
    case ${1} in
      -b|--branch)
        shift
        ztype=branch
        zrev=${1}
        ;;
      -t|--tag)
        shift
        ztype=tag
        zrev=${1}
        ;;
      -z|--frozen) zfrozen=1 ;;
      -f|--fpath)
        shift
        zarg=${1}
        [[ ${zarg} != /* ]] && zarg=${zdir}/${zarg}
        zfpaths+=(${zarg})
        ;;
      -a|--autoload)
        shift
        zfunctions+=(${1})
        ;;
      -s|--source)
        shift
        zarg=${1}
        [[ ${zarg} != /* ]] && zarg=${zdir}/${zarg}
        zscripts+=(${zarg})
        ;;
      -d|--disabled) zdisabled=1 ;;
      *)
        print -u2 -PR "%F{red}✗ ${funcfiletrace[1]}:%B${zmodule}:%b Unknown zmodule option ${1}%f"
        _zfailed=1
        return 1
        ;;
    esac
    shift
  done
  if (( _zprepare_xargs )); then
    if (( ! zfrozen )); then
      _zmodules_xargs+=${zmodule}$'\0'${zdir}$'\0'${zurl}$'\0'${ztype}$'\0'${zrev}$'\0'${_zquiet}$'\0'
    fi
  else
    if (( zdisabled )); then
      _zdisableds+=(${zmodule})
    else
      if [[ ! -d ${zdir} ]]; then
        print -u2 -PR "%F{red}✗ ${funcfiletrace[1]}:%B${zmodule}:%b Not installed%f"
        _zfailed=1
        return 1
      fi
      (( ! ${#zfpaths} )) && zfpaths+=(${zdir}/functions(NF))
      if (( ! ${#zfunctions} )); then
        # _* functions are autoloaded by compinit
        # prompt_*_setup functions are autoloaded by promptinit
        zfunctions+=(${^zfpaths}/^(*.*|_*|prompt_*_setup)(N-.:t))
      fi
      if (( ! ${#zscripts} )); then
        zscripts+=(${zdir}/(init.zsh|${zmodule:t}.(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
      fi
      _zfpaths+=(${zfpaths})
      _zfunctions+=(${zfunctions})
      _zscripts+=(${zscripts})
      _zmodules+=(${zmodule})
    fi
  fi
}

_zimfw_source_zimrc() {
  local -ri _zprepare_xargs=${1}
  local -i _zfailed=0
  if ! source ${ZDOTDIR:-${HOME}}/.zimrc || (( _zfailed )); then
    print -u2 -PR "%F{red}✗ Failed to source ${ZDOTDIR:-${HOME}}/.zimrc%f"
    return 1
  fi
}

_zimfw_clean_modules() {
  local zopt zdir zmodule
  (( ! _zquiet )) && zopt='-v'
  for zdir in ${ZIM_HOME}/modules/*(N/); do
    zmodule=${zdir:t}
    # If _zmodules and _zdisableds do not contain the zmodule
    if (( ! ${_zmodules[(I)${zmodule}]} && ! ${_zdisableds[(I)${zmodule}]} )); then
      command rm -rf ${zopt} ${zdir} || return 1
    fi
  done
  if (( ! _zquiet )); then
    print -P '%F{green}✓%f Done with clean-modules.'
  fi
}

_zimfw_clean_compiled() {
  local zopt_find zopt_rm zdir
  if (( ! _zquiet )); then
    zopt_find='-print'
    zopt_rm='-v'
  fi
  for zdir in ${fpath}; do
    [[ ${zdir} == (.|..) || ${zdir} == (.|..)/* ]] && continue
    if [[ -w ${zdir:h} ]]; then
      command rm -f ${zopt_rm} ${zdir}.zwc{,.old} || return 1
    fi
  done
  command find ${ZIM_HOME} \( -name '*.zwc' -o -name '*.zwc.old' \) -delete ${zopt_find} || return 1
  command rm -f ${zopt_rm} ${ZDOTDIR:-${HOME}}/.zshrc.zwc{,.old} || return 1
  if (( ! _zquiet )); then
    print -P '%F{green}✓%f Done with clean-compiled. Run %Bzimfw compile%b to re-compile.'
  fi
}

_zimfw_clean_dumpfile() {
  local zdumpfile zopt
  zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile="${ZDOTDIR:-${HOME}}/.zcompdump"
  (( ! _zquiet )) && zopt='-v'
  command rm -f ${zopt} ${zdumpfile}{,.zwc{,.old}} || return 1
  if (( ! _zquiet )); then
    print -P '%F{green}✓%f Done with clean-dumpfile. Restart your terminal to dump an updated configuration.'
  fi
}

_zimfw_info() {
  print 'Zim version:  1.0.0-SNAPSHOT (previous commit is 74404e6)'
  print -R 'ZIM_HOME:     '${ZIM_HOME}
  print -R 'Zsh version:  '${ZSH_VERSION}
  print -R 'System info:  '$(command uname -a)
}

_zimfw_upgrade() {
  local -r zscript=${ZIM_HOME}/zimfw.zsh
  local -r zurl=https://raw.githubusercontent.com/zimfw/zimfw/develop/zimfw.zsh
  {
    if (( ${+commands[wget]} )); then
      command wget -nv ${1} -O ${zscript}.new ${zurl} || return 1
    else
      command curl -fsSL -o ${zscript}.new ${zurl} || return 1
    fi
    if command cmp -s ${zscript}{,.new}; then
      if (( ! _zquiet )); then
        print -P '%F{green}✓%f %Bzimfw.zsh:%b Already up to date'
      fi
    else
      command mv -f ${zscript}{,.old} && command mv -f ${zscript}{.new,} && \
          if (( ! _zquiet )); then
            print -P '%F{green}✓%f %Bzimfw.zsh:%b Upgraded. Restart your terminal for changes to take effect.'
          fi
    fi
    if (( ! _zquiet )); then
      print -P '%F{green}✓%f Done with upgrade.'
    fi
  } always {
    command rm -f ${zscript}.new
  }
}

zimfw() {
  local -r zusage="
Usage: %B${0}%b <action> [%B-q%b]

Actions:
  %Bbuild%b           Build init.zsh
  %Bclean%b           Clean all (see below)
  %Bclean-modules%b   Clean unused modules
  %Bclean-compiled%b  Clean Zsh compiled files
  %Bclean-dumpfile%b  Clean completion dump file
  %Bcompile%b         Compile Zsh files
  %Binfo%b            Print Zim and system info
  %Binstall%b         Install new modules
  %Bupdate%b          Update current modules
  %Bupgrade%b         Upgrade zimfw.zsh

Options:
  %B-q%b              Quiet, only outputs errors
"
  local ztool _zmodules_xargs
  local -a _zdisableds _zmodules _zfpaths _zfunctions _zscripts
  local -i _zquiet=0
  if (( # > 2 )); then
     print -u2 -PR "%F{red}${0}: Too many options%f"$'\n'${zusage}
     return 1
  elif (( # > 1 )); then
    case ${2} in
      -q) _zquiet=1 ;;
      *)
        print -u2 -PR "%F{red}${0}: Unknown option ${2}%f"$'\n'${zusage}
        return 1
        ;;
    esac
  fi

  case ${1} in
    install)
      ztool="# This runs in a new shell
readonly MODULE=\${1}
readonly DIR=\${2}
readonly URL=\${3}
readonly REV=\${5}
readonly -i QUIET=\${6}
readonly CLEAR_LINE=$'\E[2K\r'
if [[ -e \${DIR} ]]; then
  # Already exists
  return 0
fi
(( ! QUIET )) && print -Rn \${CLEAR_LINE}\"Installing \${MODULE} …\"
if ERR=\$(command git clone -b \${REV} -q --recursive \${URL} \${DIR} 2>&1); then
  if (( ! QUIET )); then
    print -PR \${CLEAR_LINE}\"%F{green}✓%f %B\${MODULE}:%b Installed\"
  fi
else
  print -u2 -PR \${CLEAR_LINE}\"%F{red}✗ %B\${MODULE}:%b Error during git clone%f\"$'\n'\${(F):-  \${(f)^ERR}}
  return 1
fi
"
      ;;
    update)
      ztool="# This runs in a new shell
readonly MODULE=\${1}
readonly DIR=\${2}
readonly URL=\${3}
readonly TYPE=\${4}
readonly REV=\${5}
readonly -i QUIET=\${6}
readonly CLEAR_LINE=$'\E[2K\r'
(( ! QUIET )) && print -Rn \${CLEAR_LINE}\"Updating \${MODULE} …\"
if ! builtin cd \${DIR} 2>/dev/null; then
  print -u2 -PR \${CLEAR_LINE}\"%F{red}✗ %B\${MODULE}:%b Not installed%f\"
  return 1
fi
if [[ \${PWD} != \$(command git rev-parse --show-toplevel 2>/dev/null) ]]; then
  # Not in repo root. Will not try to update.
  return 0
fi
if [[ \${URL} != \$(command git config --get remote.origin.url) ]]; then
  print -u2 -PR \${CLEAR_LINE}\"%F{red}✗ %B\${MODULE}:%b URL does not match. Expected \${URL}. Will not try to update.%f\"
  return 1
fi
if [[ \${TYPE} == tag ]]; then
  if [[ \${REV} == \$(command git describe --tags --exact-match 2>/dev/null) ]]; then
    (( ! QUIET )) && print -PR \${CLEAR_LINE}\"%F{green}✓%f %B\${MODULE}:%b Already up to date\"
    return 0
  fi
fi
if ! ERR=\$(command git fetch -pq origin \${REV} 2>&1); then
  print -u2 -PR \${CLEAR_LINE}\"%F{red}✗ %B\${MODULE}:%b Error during git fetch%f\"$'\n'\${(F):-  \${(f)^ERR}}
  return 1
fi
if [[ \${TYPE} == branch ]]; then
  LOG_REV=\${REV}@{u}
else
  LOG_REV=\${REV}
fi
LOG=\$(command git log --graph --color --format='%C(yellow)%h%C(reset) %s %C(cyan)(%cr)%C(reset)' ..\${LOG_REV} 2>/dev/null)
if ! ERR=\$(command git checkout -q \${REV} -- 2>&1); then
  print -u2 -PR \${CLEAR_LINE}\"%F{red}✗ %B\${MODULE}:%b Error during git checkout%f\"$'\n'\${(F):-  \${(f)^ERR}}
  return 1
fi
if [[ \${TYPE} == branch ]]; then
  if ! OUT=\$(command git merge --ff-only --no-progress -n 2>&1); then
    print -u2 -PR \${CLEAR_LINE}\"%F{red}✗ %B\${MODULE}:%b Error during git merge%f\"$'\n'\${(F):-  \${(f)^OUT}}
    return 1
  fi
  # keep just first line of OUT
  OUT=\${OUT%%($'\n'|$'\r')*}
else
  OUT=\"Updating to \${TYPE} \${REV}\"
fi
if ERR=\$(command git submodule update --init --recursive -q 2>&1); then
  if (( ! QUIET )); then
    [[ -n \${LOG} ]] && OUT=\${OUT}$'\n'\${(F):-  \${(f)^LOG}}
    print -PR \${CLEAR_LINE}\"%F{green}✓%f %B\${MODULE}:%b \${OUT}\"
  fi
else
  print -u2 -PR \${CLEAR_LINE}\"%F{red}✗ %B\${MODULE}:%b Error during git submodule update%f\"$'\n'\${(F):-  \${(f)^ERR}}
  return 1
fi
"
      ;;
  esac

  case ${1} in
    build) _zimfw_source_zimrc && _zimfw_build && _zimfw_compile ${2} ;;
    init) _zimfw_source_zimrc && _zimfw_build ;;
    clean)
      _zimfw_source_zimrc && \
          _zimfw_clean_modules && \
          _zimfw_clean_compiled && \
          _zimfw_clean_dumpfile
      ;;
    clean-modules) _zimfw_source_zimrc && _zimfw_clean_modules ;;
    clean-compiled) _zimfw_clean_compiled ;;
    clean-dumpfile) _zimfw_clean_dumpfile ;;
    compile|login-init) _zimfw_source_zimrc && _zimfw_compile ${2} ;;
    info) _zimfw_info ;;
    install|update)
      _zimfw_source_zimrc 1 || return 1
      print -Rn ${_zmodules_xargs} | xargs -0 -n6 -P10 zsh -c ${ztool} ${1} && \
          if (( ! _zquiet )); then
            print -PR "%F{green}✓%f Done with ${1}. Restart your terminal for any changes to take effect."
          fi && \
          _zimfw_source_zimrc && _zimfw_build && _zimfw_compile ${2}
      ;;
    upgrade) _zimfw_upgrade && _zimfw_compile ;;
    *)
      print -u2 -PR "%F{red}${0}: Unknown action ${1}%f"$'\n'${zusage}
      return 1
      ;;
  esac
}

zimfw "${@}"
