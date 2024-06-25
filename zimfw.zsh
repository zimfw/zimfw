# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

# MIT License
#
# Copyright (c) 2015-2016 Matt Hamilton and contributors
# Copyright (c) 2016-2024 Eric Nielsen, Matt Hamilton and contributors
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
  print -u2 -R $'\E[31m'${0}$': Error starting zimfw. You\'re using Zsh version \E[1m'${ZSH_VERSION}$'\E[0;31m and versions < \E[1m5.2\E[0;31m are not supported. Upgrade your Zsh.\E[0m'
  return 1
fi
autoload -Uz zargs

if (( ! ${+ZIM_HOME} )); then
  print -u2 -R $'\E[31m'${0}$': \E[1mZIM_HOME\E[0;31m not defined\E[0m'
  return 1
fi
# Define zimfw location
typeset -g __ZIMFW_FILE=${0}

_zimfw_print() {
  if (( _zprintlevel > 0 )) print "${@}"
}

_zimfw_mv() {
  local -a cklines
  if cklines=(${(f)"$(command cksum ${1} ${2} 2>/dev/null)"}) && \
      [[ ${${(z)cklines[1]}[1,2]} == ${${(z)cklines[2]}[1,2]} ]]; then
    _zimfw_print -R $'\E[32m)\E[0m \E[1m'${2}$':\E[0m Already up to date'
  else
    if [[ -e ${2} ]]; then
      command mv -f ${2}{,.old} || return 1
    fi
    command mv -f ${1} ${2} && command chmod a+r ${2} && _zimfw_print -R $'\E[32m)\E[0m \E[1m'${2}$':\E[0m Updated.'${_zrestartmsg}
  fi
}

_zimfw_build_init() {
  local -r ztarget=${ZIM_HOME}/init.zsh
  # Force update of init.zsh if it's older than .zimrc
  if [[ ${ztarget} -ot ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
    command mv -f ${ztarget}{,.old} || return 1
  fi
  _zimfw_mv =(
    print -R 'if (( ${+ZIM_HOME} )) zimfw() { source '${${(qqq)__ZIMFW_FILE}/${HOME}/\${HOME}}' "${@}" }'
    local zroot_dir zpre
    local -a zif_functions zif_cmds zroot_functions zroot_cmds
    local -a zfunctions=(${_zfunctions}) zcmds=(${_zcmds})
    # Keep fpath constant regardless of "if" root dirs, to avoid confusing compinit.
    # Move all from zfunctions and zcmds with "if" root dirs prefixes.
    for zroot_dir in ${_zroot_dirs}; do
      if (( ${+_zifs[${zroot_dir}]} )); then
        zpre=${zroot_dir}$'\0'
        zif_functions+=(${(M)zfunctions:#${zpre}*})
        zif_cmds+=(${(M)zcmds:#${zpre}*})
        zfunctions=(${zfunctions:#${zpre}*})
        zcmds=(${zcmds:#${zpre}*})
      fi
    done
    zpre=$'*\0'
    if (( ${#_zfpaths} )) print -R 'fpath=('${${(qqq)${_zfpaths#${~zpre}}:a}/${HOME}/\${HOME}}' ${fpath})'
    if (( ${#zfunctions} )) print -R 'autoload -Uz -- '${zfunctions#${~zpre}}
    for zroot_dir in ${_zroot_dirs}; do
      zpre=${zroot_dir}$'\0'
      if (( ${+_zifs[${zroot_dir}]} )); then
        zroot_functions=(${${(M)zif_functions:#${zpre}*}#${zpre}})
        zroot_cmds=(${${(M)zif_cmds:#${zpre}*}#${zpre}})
        if (( ${#zroot_functions} || ${#zroot_cmds} )); then
          print -R 'if '${_zifs[${zroot_dir}]}'; then'
          if (( ${#zroot_functions} )) print -R '  autoload -Uz -- '${zroot_functions}
          if (( ${#zroot_cmds} )) print -R ${(F):-  ${^zroot_cmds}}
          print fi
        fi
      else
        zroot_cmds=(${${(M)zcmds:#${zpre}*}#${zpre}})
        if (( ${#zroot_cmds} )) print -R ${(F)zroot_cmds}
      fi
    done
  ) ${ztarget}
}

_zimfw_build_login_init() {
  local -r ztarget=${ZIM_HOME}/login_init.zsh
  # Force update of login_init.zsh if it's older than .zimrc
  if [[ ${ztarget} -ot ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
    command mv -f ${ztarget}{,.old} || return 1
  fi
  _zimfw_mv =(
    print '# Do nothing. This file is deprecated.'
  ) ${ztarget}
}

_zimfw_build() {
  _zimfw_build_init && _zimfw_build_login_init && _zimfw_print 'Done with build.'
}

_zimfw_source_zimrc() {
zmodule() {
  local -r ztarget=${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc}
  local -r zusage=$'Usage: \E[1m'${0}$'\E[0m <url> [\E[1m-n\E[0m|\E[1m--name\E[0m <module_name>] [\E[1m-r\E[0m|\E[1m--root\E[0m <path>] [options]

Add \E[1mzmodule\E[0m calls to your \E[1m'${ztarget}$'\E[0m file to define the modules to be initialized.
The initialization will be done in the same order it\'s defined.

  <url>                      Module absolute path or repository URL. The following URL formats
                             are equivalent: \E[1mfoo\E[0m, \E[1mzimfw/foo\E[0m, \E[1mhttps://github.com/zimfw/foo.git\E[0m.
                             If an absolute path is given, the module is considered externally
                             installed and won\'t be installed or updated by zimfw.
  \E[1m-n\E[0m|\E[1m--name\E[0m <module_name>    Set a custom module name. Default: the last component in <url>.
                             Slashes can be used inside the name to organize the module into
                             subdirectories. The module will be installed at
                             \E[1m'${ZIM_HOME}$'/\E[0m<module_name>.
  \E[1m-r\E[0m|\E[1m--root\E[0m <path>           Relative path to the module root.

Per-module options:
  \E[1m-b\E[0m|\E[1m--branch\E[0m <branch_name>  Use specified branch when installing and updating the module.
                             Overrides the tag option. Default: the repository default branch.
  \E[1m-t\E[0m|\E[1m--tag\E[0m <tag_name>        Use specified tag when installing and updating the module. Over-
                             rides the branch option.
  \E[1m-u\E[0m|\E[1m--use\E[0m <tool_name>       Install and update the module using the defined tool. Default is
                             either defined by \E[1mzstyle \':zim:zmodule\' use \'\E[0m<tool_name>\E[1m\'\E[0m, or \E[1mgit\E[0m
                             if none is provided. The tools available are:
                             \E[1mgit\E[0m uses the git command. Local changes are preserved on updates.
                             \E[1mdegit\E[0m uses curl or wget, and currently only works with GitHub
                             URLs. Modules install faster and take less disk space. Local
                             changes are lost on updates. Git submodules are not supported.
                             \E[1mmkdir\E[0m creates an empty directory. The <url> is only used to set
                             the module name. Use the \E[1m-c\E[0m|\E[1m--cmd\E[0m or \E[1m--on-pull\E[0m options to execute
                             the desired command to generate the module files.
  \E[1m--no-submodules\E[0m            Don\'t install or update git submodules.
  \E[1m-z\E[0m|\E[1m--frozen\E[0m                Don\'t install or update the module.

  The per-module options above are carried over multiple zmodule calls for the same module.
  Modules are uniquely identified by their name.

Per-module-root options:
  \E[1m--if\E[0m <test>                Will only initialize module root if specified test returns a zero
                             exit status. The test is evaluated at every new terminal startup.
  \E[1m--if-command\E[0m <cmd_name>    Will only initialize module root if specified external command is
                             available. This is evaluated at every new terminal startup.
                             Equivalent to \E[1m--if \'(( \${+commands[\E[0m<cmd_name>\E[1m]} ))\'\E[0m.
  \E[1m--on-pull\E[0m <command>        Execute command after installing or updating the module. The com-
                             mand is executed in the module root directory.
  \E[1m-d\E[0m|\E[1m--disabled\E[0m              Don\'t initialize the module root or uninstall the module.

  The per-module-root options above are carried over multiple zmodule calls for the same mod-
  ule root.

Per-call initialization options:
  \E[1m-f\E[0m|\E[1m--fpath\E[0m <path>          Will add specified path to fpath. The path is relative to the
                             module root directory. Default: \E[1mfunctions\E[0m, if the subdirectory
                             exists and is non-empty.
  \E[1m-a\E[0m|\E[1m--autoload\E[0m <func_name>  Will autoload specified function. Default: all valid names inside
                             the \E[1mfunctions\E[0m subdirectory, if any.
  \E[1m-s\E[0m|\E[1m--source\E[0m <file_path>    Will source specified file. The path is relative to the module
                             root directory. Default: \E[1minit.zsh\E[0m, if a non-empty \E[1mfunctions\E[0m sub-
                             directory exists, else the largest of the files matching the glob
                             \E[1m(init.zsh|\E[0m<name>\E[1m.(zsh|plugin.zsh|zsh-theme|sh))\E[0m, if any.
                             <name> in the glob is resolved to the last component of the mod-
                             ule name, or the last component of the path to the module root.
  \E[1m-c\E[0m|\E[1m--cmd\E[0m <command>         Will execute specified command. Occurrences of the \E[1m{}\E[0m placeholder
                             in the command are substituted by the module root directory path.
                             I.e., \E[1m-s \'foo.zsh\'\E[0m and \E[1m-c \'source {}/foo.zsh\'\E[0m are equivalent.

  Setting any per-call initialization option above will disable the default values from the
  other per-call initialization options, so only your provided values will be used. I.e. these
  values are either all automatic, or all manual in each zmodule call. To use default values
  and also provided values, use separate zmodule calls.'
  if [[ ${${funcfiletrace[1]%:*}:A} != ${ztarget:A} ]]; then
    print -u2 -lR $'\E[31m'${0}$': Must be called from \E[1m'${ztarget}$'\E[0m' '' ${zusage}
    return 2
  fi
  if (( ! # )); then
    print -u2 -lR $'\E[31mx '${funcfiletrace[1]}$': Missing zmodule url\E[0m' '' ${zusage}
    _zfailed=1
    return 2
  fi
  local zurl=${1} zname=${1:t} zroot zarg
  local -a zfpaths zfunctions zcmds
  if [[ ${zurl} =~ ^[^:/]+: ]]; then
    zname=${zname%.git}
  elif [[ ${zurl} != /* ]]; then
    # Count number of slashes
    case ${#zurl//[^\/]/} in
      0) zurl=https://github.com/zimfw/${zurl}.git ;;
      1) zurl=https://github.com/${zurl}.git ;;
    esac
  fi
  shift
  while [[ ${1} == (-n|--name|-r|--root) ]]; do
    if (( # < 2 )); then
      print -u2 -lR $'\E[31mx '${funcfiletrace[1]}$':\E[1m'${zname}$':\E[0;31m Missing argument for zmodule option \E[1m'${1}$'\E[0m' '' ${zusage}
      _zfailed=1
      return 2
    fi
    case ${1} in
      -n|--name)
        shift
        zname=${${1%%/##}##/##}
        ;;
      -r|--root)
        shift
        zroot=${${1%%/##}##/##}
        ;;
    esac
    shift
  done
  if [[ ${zurl} == /* ]]; then
    _zdirs[${zname}]=${zurl%%/##}
    zurl=
  else
    _zdirs[${zname}]=${ZIM_HOME}/modules/${zname}
  fi
  if [[ ${+_zurls[${zname}]} -ne 0 && ${_zurls[${zname}]} != ${zurl} ]]; then
    print -u2 -lR $'\E[31mx '${funcfiletrace[1]}$':\E[1m'${zname}$':\E[0;31m Module already defined with a different URL. Expected \E[1m'${_zurls[${zname}]}$'\E[0m' '' ${zusage}
    _zfailed=1
    return 2
  fi
  _zurls[${zname}]=${zurl}
  local -r zroot_dir=${_zdirs[${zname}]}${zroot:+/${zroot}}
  _zroot_dirs+=(${zroot_dir})
  # Set default values
  if (( ! ${+_ztools[${zname}]} )); then
    zstyle -s ':zim:zmodule' use "_ztools[${zname}]" || _ztools[${zname}]=git
  fi
  if (( ! ${+_ztypes[${zname}]} )) _ztypes[${zname}]=branch
  if (( ! ${+_zsubmodules[${zname}]} )) _zsubmodules[${zname}]=1
  # Set values from options
  while (( # > 0 )); do
    case ${1} in
      -b|--branch|-t|--tag|-u|--use|--on-pull|--if|--if-command|-f|--fpath|-a|--autoload|-s|--source|-c|--cmd)
        if (( # < 2 )); then
          print -u2 -lR $'\E[31mx '${funcfiletrace[1]}$':\E[1m'${zname}$':\E[0;31m Missing argument for zmodule option \E[1m'${1}$'\E[0m' '' ${zusage}
          _zfailed=1
          return 2
        fi
        ;;
    esac
    case ${1} in
      -b|--branch|-t|--tag|-u|--use|--no-submodules)
        if [[ -z ${zurl} ]] _zimfw_print -u2 -R $'\E[33m! '${funcfiletrace[1]}$':\E[1m'${zname}$':\E[0;33m The zmodule option \E[1m'${1}$'\E[0;33m has no effect for external modules\E[0m'
        ;;
    esac
    case ${1} in
      -b|--branch)
        shift
        _ztypes[${zname}]=branch
        _zrevs[${zname}]=${1}
        ;;
      -t|--tag)
        shift
        _ztypes[${zname}]=tag
        _zrevs[${zname}]=${1}
        ;;
      -u|--use)
        shift
        _ztools[${zname}]=${1}
        ;;
      --no-submodules) _zsubmodules[${zname}]=0 ;;
      -z|--frozen) _zfrozens[${zname}]=1 ;;
      --on-pull)
        shift
        zarg=${1}
        if [[ -n ${zroot} ]] zarg="(builtin cd -q ${zroot}; ${zarg})"
        _zonpulls[${zname}]="${_zonpulls[${zname}]+${_zonpulls[${zname}]}; }${zarg}"
        ;;
      --if)
        shift
        _zifs[${zroot_dir}]=${1}
        ;;
      --if-command)
        shift
        _zifs[${zroot_dir}]="(( \${+commands[${1}]} ))"
        ;;
      -f|--fpath)
        shift
        zarg=${1}
        if [[ ${zarg} != /* ]] zarg=${zroot_dir}/${zarg}
        zfpaths+=(${zarg})
        ;;
      -a|--autoload)
        shift
        zfunctions+=(${1})
        ;;
      -s|--source)
        shift
        zarg=${1}
        if [[ ${zarg} != /* ]] zarg=${zroot_dir}/${zarg}
        zcmds+=('source '${(qqq)zarg:a})
        ;;
      -c|--cmd)
        shift
        zcmds+=(${1//{}/${(qqq)zroot_dir:a}})
        ;;
      -d|--disabled) _zdisabled_root_dirs+=(${zroot_dir}) ;;
      *)
        print -u2 -lR $'\E[31mx '${funcfiletrace[1]}$':\E[1m'${zname}$':\E[0;31m Unknown zmodule option \E[1m'${1}$'\E[0m' '' ${zusage}
        _zfailed=1
        return 2
        ;;
    esac
    shift
  done
  if (( _zflags & 1 )); then
    _znames+=(${zname})
  fi
  if (( _zflags & 2 )); then
    if [[ ! -e ${zroot_dir} ]]; then
      print -u2 -R $'\E[31mx '${funcfiletrace[1]}$':\E[1m'${zname}': '${zroot_dir}$'\E[0;31m not found\E[0m'
      _zfailed=1
      return 1
    fi
    if (( ! ${#zfpaths} && ! ${#zfunctions} && ! ${#zcmds} )); then
      zfpaths=(${zroot_dir}/functions(NF))
      # _* functions are autoloaded by compinit
      # prompt_*_setup functions are autoloaded by promptinit
      zfunctions=(${^zfpaths}/^(*~|*.zwc(|.old)|_*|prompt_*_setup)(N-.:t))
      local -ra prezto_scripts=(${zroot_dir}/init.zsh(N))
      if (( ${#zfpaths} && ${#prezto_scripts} )); then
        # this follows the prezto module format, no need to check for other scripts
        zcmds=('source '${(qqq)^prezto_scripts:a})
      else
        # get script with largest size (descending `O`rder by `L`ength, and return only `[1]` first)
        local -ra zscripts=(${zroot_dir}/(init.zsh|(${zname:t}|${zroot_dir:t}).(zsh|plugin.zsh|zsh-theme|sh))(NOL[1]))
        zcmds=('source '${(qqq)^zscripts:a})
      fi
    fi
    if (( ! ${#zfpaths} && ! ${#zfunctions} && ! ${#zcmds} )); then
      _zimfw_print -u2 -lR $'\E[33m! '${funcfiletrace[1]}$':\E[1m'${zname}$':\E[0;33m Nothing found to be initialized. Customize the module name, root or initialization with \E[1mzmodule\E[0;33m options.\E[0m' '' ${zusage}
    fi
    # Prefix is added to all _zfpaths, _zfunctions and _zcmds to distinguish the originating root dir
    local -r zpre=${zroot_dir}$'\0'
    _zfpaths+=(${zpre}${^zfpaths})
    _zfunctions+=(${zpre}${^zfunctions})
    zcmds=(${zcmds//${HOME}/\${HOME}})
    _zcmds+=(${zpre}${^zcmds})
  fi
}

  {
    local -r ztarget=${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} _zflags=${1}
    local -i _zfailed=0
    if ! source ${ztarget} || (( _zfailed )); then
      print -u2 -R $'\E[31mFailed to source \E[1m'${ztarget}$'\E[0m'
      return 1
    fi
    if (( _zflags & 1 && ${#_znames} == 0 )); then
      print -u2 -R $'\E[31mNo modules defined in \E[1m'${ztarget}$'\E[0m'
      return 1
    fi
    # Remove all from _zfpaths, _zfunctions and _zcmds with disabled root dirs prefixes
    local zroot_dir zpre
    for zroot_dir in ${_zdisabled_root_dirs}; do
      zpre=${zroot_dir}$'\0'
      _zfpaths=(${_zfpaths:#${zpre}*})
      _zfunctions=(${_zfunctions:#${zpre}*})
      _zcmds=(${_zcmds:#${zpre}*})
    done
  } always {
    unfunction zmodule
  }
}

_zimfw_list_unuseds() {
  local -i i=1
  local zinstalled=(${ZIM_HOME}/modules/*(N/))
  local -r zdirs=(${(v)_zdirs})
  # Search into subdirectories
  while (( i <= ${#zinstalled} )); do
    if (( ${zdirs[(I)${zinstalled[i]}/*]} )); then
      zinstalled+=(${zinstalled[i]}/*(N/))
      zinstalled[i]=()
    else
      (( i++ ))
    fi
  done
  # Unused = all installed dirs not in zdirs
  _zunused_dirs=(${zinstalled:|zdirs})
  local zunused
  for zunused (${_zunused_dirs}) _zimfw_print -R $'\E[1m'${zunused:t}$':\E[0m '${zunused}${1}
}

_zimfw_check_dumpfile() {
  _zimfw_print -u2 $'\E[33m! Deprecated action. This is now handled by the completion module alone.\E[0m'
}

_zimfw_check_version() {
  if (( ${1} )); then
    if (( ${2} )); then
      # background check
      if [[ -w ${_zversion_target:h} ]]; then
        print -R ${${${(f)"$(GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=30 command git ls-remote --tags --refs --sort=-v:refname \
            https://github.com/zimfw/zimfw.git 'v*' 2>/dev/null)"}##*v}[1]} >! ${_zversion_target} &!
      fi
    else
      # foreground check
      local tags
      tags=$(command git ls-remote --tags --refs --sort=-v:refname https://github.com/zimfw/zimfw.git 'v*') || return 1
      >! ${_zversion_target} <<<${${${(f)tags}##*v}[1]} || return 1
    fi
  fi
  if [[ -f ${_zversion_target} ]]; then
    local -r zlatest_version=$(<${_zversion_target})
    if [[ -n ${zlatest_version} && ${_zversion} != ${zlatest_version} ]]; then
      _zimfw_print -u2 -R $'\E[33mLatest zimfw version is \E[1m'${zlatest_version}$'\E[0;33m. You\'re using version \E[1m'${_zversion}$'\E[0;33m. Run \E[1mzimfw upgrade\E[0;33m to upgrade.\E[0m'
      return 4
    fi
  fi
}

_zimfw_clean_compiled() {
  # Array with unique dirs. ${ZIM_HOME} or any subdirectory should only occur once.
  local -Ur zscriptdirs=(${ZIM_HOME:A} ${${(v)_zdirs##${ZIM_HOME:A}/*}:A})
  local zopt
  if (( _zprintlevel > 0 )) zopt=-v
  command rm -f ${zopt} ${^zscriptdirs}/**/*.zwc(|.old)(N) && \
      _zimfw_print $'Done with clean-compiled. Restart your terminal or run \E[1mzimfw compile\E[0m to re-compile.'
}

_zimfw_clean_dumpfile() {
  local zdumpfile zopt
  zstyle -s ':zim:completion' dumpfile 'zdumpfile' || zdumpfile=${ZDOTDIR:-${HOME}}/.zcompdump
  if (( _zprintlevel > 0 )) zopt=-v
  command rm -f ${zopt} ${zdumpfile}(|.dat|.zwc(|.old))(N) && \
      _zimfw_print -R "Done with clean-dumpfile.${_zrestartmsg}"
}

_zimfw_compile() {
  # Compile zimfw scripts
  local zroot_dir zfile
  for zroot_dir in ${_zroot_dirs:|_zdisabled_root_dirs}; do
    if [[ ! -w ${zroot_dir} ]]; then
      _zimfw_print -R $'\E[33m! \E[1m'${zroot_dir}$':\E[0;33m No write permission, unable to compile.\E[0m'
      continue
    fi
    for zfile in ${zroot_dir}/(^*test*/)#*.zsh(|-theme)(N-.); do
      if [[ ! ${zfile}.zwc -nt ${zfile} ]]; then
        zcompile -UR ${zfile} && _zimfw_print -R $'\E[32m)\E[0m \E[1m'${zfile}$'.zwc:\E[0m Compiled'
      fi
    done
  done
  _zimfw_print 'Done with compile.'
}

_zimfw_info() {
  print -R 'zimfw version:        '${_zversion}' (built at 2024-06-25 17:29:35 UTC, previous commit is 3b7908d)'
  local zparam
  for zparam in LANG ${(Mk)parameters:#LC_*} OSTYPE TERM TERM_PROGRAM TERM_PROGRAM_VERSION ZIM_HOME ZSH_VERSION; do
    print -R ${(r.22....:.)zparam}${(P)zparam}
  done
}

_zimfw_uninstall() {
  local zopt
  if (( _zprintlevel > 0 )) zopt=-v
  if (( ${#_zunused_dirs} )); then
    if (( _zprintlevel <= 0 )) || read -q "?Uninstall ${#_zunused_dirs} module(s) listed above [y/N]? "; then
      _zimfw_print
      command rm -rf ${zopt} ${_zunused_dirs} || return 1
    fi
  fi
  _zimfw_print 'Done with uninstall.'
}

_zimfw_upgrade() {
  local -r ztarget=${__ZIMFW_FILE:A} zurl=https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh.gz
  if [[ ! -w ${ztarget:h} ]]; then
    print -u2 -R $'\E[31mNo write permission to \E[1m'${ztarget:h}$'\E[0;31m. Will not try to upgrade.\E[0m'
    return 1
  fi
  {
    if (( ${+commands[curl]} )); then
      command curl -fsSL -o ${ztarget}.new.gz ${zurl} || return 1
    else
      local zopt
      if (( _zprintlevel <= 1 )) zopt=-q
      if ! command wget -nv ${zopt} -O ${ztarget}.new.gz ${zurl}; then
        if (( _zprintlevel <= 1 )); then
          print -u2 -R $'\E[31mFailed to download \E[1m'${zurl}$'\E[0;31m. Use \E[1m-v\E[0;31m option to see details.\E[0m'
        fi
        return 1
      fi
    fi
    command gunzip -f ${ztarget}.new.gz || return 1
    # .latest_version can be outdated and will yield a false warning if zimfw is
    # upgraded before .latest_version is refreshed. Bad thing about having a cache.
    _zimfw_mv ${ztarget}{.new,} && command rm -f ${ZIM_HOME}/.latest_version && \
        _zimfw_print 'Done with upgrade.'
  } always {
    command rm -f ${ztarget}.new{,.gz}
  }
}

_zimfw_run_list() {
  local -r zname=${1}
  local -r zdir=${_zdirs[${zname}]}
  print -nR $'\E[1m'${zname}$':\E[0m '${zdir}
  if [[ -z ${_zurls[${zname}]} ]] print -n ' (external)'
  if (( ${_zfrozens[${zname}]} )) print -n ' (frozen)'
  if (( ${_zdisabled_root_dirs[(I)${zdir}]} )) print -n ' (disabled)'
  print
  if (( _zprintlevel > 1 )); then
    if [[ ${_zfrozens[${zname}]} -eq 0 && -n ${_zurls[${zname}]} ]]; then
      print -nR "  From: ${_zurls[${zname}]}, "
      if [[ -z ${_zrevs[${zname}]} ]]; then
        print -n 'default branch'
      else
        print -nR "${_ztypes[${zname}]} ${_zrevs[${zname}]}"
      fi
      print -nR ", using ${_ztools[${zname}]}"
      if (( ! _zsubmodules[${zname}] )) print -n ', no git submodules'
      print
      if [[ -n ${_zonpulls[${zname}]} ]] print -R "  On-pull: ${_zonpulls[${zname}]}"
    fi
    # Match the current module dir prefix from _zroot_dirs
    local -r zroot_dirs=(${(M)_zroot_dirs:#${zdir}/*})
    if (( ${#zroot_dirs} )); then
      print '  Additional root:'
      local zroot_dir
      for zroot_dir in ${zroot_dirs}; do
        print -nR "    ${zroot_dir}"
        if (( ${_zdisabled_root_dirs[(I)${zroot_dir}]} )) print -n ' (disabled)'
        print
      done
    fi
    # Match and remove the prefix from _zfpaths, _zfunctions and _zcmds
    local -r zpre="${(q)zdir}(|/*)"$'\0'
    local -r zfpaths=(${${(M)_zfpaths:#${~zpre}*}#${~zpre}}) zfunctions=(${${(M)_zfunctions:#${~zpre}*}#${~zpre}}) zcmds=(${${(M)_zcmds:#${~zpre}*}#${~zpre}})
    if (( ${#zfpaths} )) print -R '  fpath: '${zfpaths}
    if (( ${#zfunctions} )) print -R '  autoload: '${zfunctions}
    if (( ${#zcmds} )) print -R '  cmd: '${(j:; :)zcmds}
  fi
}

_zimfw_create_dir() {
  if ! ERR=$(command mkdir -p ${1} 2>&1); then
    _zimfw_print_error "Error creating ${1}" ${ERR}
    return 1
  fi
}

_zimfw_print_error() {
  print -u2 -lR $'\E[2K\r\E[31mx \E[1m'${_zname}$':\E[0;31m '${1}$'\E[0m' ${2:+${(F):-  ${(f)^2}}}
}

_zimfw_print_okay() {
  if (( _zprintlevel > ${2:-0} )) print -lR $'\E[2K\r\E[32m)\E[0m \E[1m'${_zname}$':\E[0m '${1} ${3:+${(F):-  ${(f)^3}}}
}

_zimfw_print_warn() {
  _zimfw_print -u2 -R $'\E[2K\r\E[33m! \E[1m'${_zname}$':\E[0;33m '${1}$'\E[0m'
}

_zimfw_pull_print_okay() {
  # Useb by tools, which run in a subshell
  if [[ -n ${ONPULL} ]]; then
    if ! ERR=$(builtin cd -q ${DIR} 2>&1 && builtin eval ${ONPULL} 2>&1); then
      _zimfw_print_error 'Error during on-pull' ${ERR}
      return 1
    elif [[ ${_zprintlevel} -gt 1 && -n ${ERR} ]]; then
      # Overrides ${3} to include the on-pull output, to be used by _zimfw_print_okay below.
      builtin set ${1} ${2:-0} ${3:+${3}$'\n'}'On-pull output:'$'\n'${ERR}
    fi
  fi
  _zimfw_print_okay "${@}"
}

_zimfw_download_tarball() {
  if [[ ${URL} =~ ^([^:@/]+://)?([^@]+@)?([^:/]+)[:/]([^/]+/[^/]+)/?$ ]]; then
    readonly HOST=${match[3]}
    readonly REPO=${match[4]%.git}
  fi
  if [[ ${HOST} != github.com || -z ${REPO} ]]; then
    _zimfw_print_error ${URL}$' is not a valid URL. Will not try to '${_zaction}$'. The zimfw degit tool only supports GitHub URLs. Use zmodule option \E[1m--use git\E[0;31m to use git instead.'
    return 1
  fi
  readonly HEADERS_TARGET=${DIR}/${TEMP}_headers
  {
    if [[ -r ${INFO_TARGET} ]]; then
      readonly INFO=("${(@f)"$(<${INFO_TARGET})"}")
      if [[ ${URL} != ${INFO[1]} ]]; then
        _zimfw_print_error "The zimfw degit URL does not match. Expected ${URL}. Will not try to ${_zaction}."
        return 1
      fi
      # Previous REV is in line 2, reserved for future use.
      readonly INFO_HEADER=${INFO[3]}
    fi
    readonly TARBALL_URL=https://api.github.com/repos/${REPO}/tarball/${REV}
    if [[ ${_zaction} == check ]]; then
      if [[ -z ${INFO_HEADER} ]] return 0
      if (( ${+commands[curl]} )); then
        command curl -IfsL -H ${INFO_HEADER} ${TARBALL_URL} >${HEADERS_TARGET}
      else
        command wget --spider -qS --header=${INFO_HEADER} ${TARBALL_URL} 2>${HEADERS_TARGET}
      fi
    else
      if (( ${+commands[curl]} )); then
        if ! ERR=$(command curl -fsSL ${INFO_HEADER:+-H} ${INFO_HEADER} -o ${TARBALL_TARGET} -D ${HEADERS_TARGET} ${TARBALL_URL} 2>&1); then
          _zimfw_print_error "Error downloading ${TARBALL_URL} with curl" ${ERR}
          return 1
        fi
      else
        # wget returns 8 when 304 Not Modified, so we cannot use wget's error codes
        command wget -qS ${INFO_HEADER:+--header=${INFO_HEADER}} -O ${TARBALL_TARGET} ${TARBALL_URL} 2>${HEADERS_TARGET}
      fi
    fi
    while IFS= read -r HEADER; do
      HEADER=${${HEADER## ##}%%$'\r'##}
      if [[ ${HEADER} == HTTP/* ]]; then
        HTTP_CODE=${${(s: :)HEADER}[2]}
      elif [[ ${${(L)HEADER%%:*}%% ##} == etag ]]; then
        ETAG=${${HEADER#*:}## ##}
      fi
    done < ${HEADERS_TARGET}
    if (( HTTP_CODE == 304 )); then
      # Not Modified
      command rm -f ${TARBALL_TARGET} 2>/dev/null
      return 0
    elif (( HTTP_CODE != 200 )); then
      _zimfw_print_error "Error downloading ${TARBALL_URL}, HTTP code ${HTTP_CODE}"
      return 1
    fi
    if [[ -z ${ETAG} ]]; then
      _zimfw_print_error "Error downloading ${TARBALL_URL}, no ETag header found in response"
      return 1
    fi
    if [[ ${_zaction} == check ]]; then
      command touch ${TARBALL_TARGET} # Update available
    else
      if ! print -lR "${URL}" "${REV}" "If-None-Match: ${ETAG}" >! ${INFO_TARGET} 2>/dev/null; then
        _zimfw_print_error "Error creating or updating ${INFO_TARGET}"
        return 1
      fi
    fi
  } always {
    command rm -f ${HEADERS_TARGET} 2>/dev/null
  }
}

_zimfw_untar_tarball() {
  if ! ERR=$(command tar -C ${1} -xzf ${TARBALL_TARGET} 2>&1); then
    _zimfw_print_error "Error extracting ${TARBALL_TARGET}" ${ERR}
    return 1
  fi
  local zsubdir
  for zsubdir in ${1}/*(/); do
    if ! ERR=$(command mv -f ${zsubdir}/*(DN) ${1} 2>&1 && command rmdir ${zsubdir} 2>&1); then
      _zimfw_print_error "Error moving ${zsubdir}" ${ERR}
      return 1
    fi
  done
}

_zimfw_tool_degit() {
  # This runs in a subshell
  readonly -i SUBMODULES=${5}
  readonly DIR=${1} URL=${2} REV=${4} ONPULL=${6} TEMP=.zdegit_${sysparams[pid]}
  readonly TARBALL_TARGET=${DIR}/${TEMP}_tarball.tar.gz INFO_TARGET=${DIR}/.zdegit
  case ${_zaction} in
    install)
      {
        _zimfw_create_dir ${DIR} && _zimfw_download_tarball && _zimfw_untar_tarball ${DIR} && _zimfw_pull_print_okay Installed || return 1
      } always {
        # return 1 does not change ${TRY_BLOCK_ERROR}, only changes ${?}
        (( TRY_BLOCK_ERROR = ? ))
        command rm -f ${TARBALL_TARGET} 2>/dev/null
        if (( TRY_BLOCK_ERROR )) command rm -rf ${DIR} 2>/dev/null
      }
      ;;
    check|update)
      if [[ ! -r ${INFO_TARGET} ]]; then
        _zimfw_print_warn $'Module was not installed using zimfw\'s degit. Will not try to '${_zaction}$'. Use zmodule option \E[1m-z\E[0;33m|\E[1m--frozen\E[0;33m to disable this warning.'
        return 0
      fi
      readonly DIR_NEW=${DIR}${TEMP}
      {
        _zimfw_download_tarball || return 1
        if [[ ${_zaction} == check ]]; then
          if [[ -e ${TARBALL_TARGET} ]]; then
            _zimfw_print_okay 'Update available'
            return 4
          fi
          _zimfw_print_okay 'Already up to date' 1
          return 0
        else
          if [[ -e ${TARBALL_TARGET} ]]; then
            _zimfw_create_dir ${DIR_NEW} && _zimfw_untar_tarball ${DIR_NEW} || return 1
            if (( ${+commands[diff]} )); then
              LOG=$(command diff -x '.zdegit*' -x '*.zwc' -x '*.zwc.old' -qr ${DIR} ${DIR_NEW} 2>/dev/null)
              LOG=${${LOG//${DIR_NEW}/new}//${DIR}/old}
            fi
            if ! ERR=$({ command cp -f ${INFO_TARGET} ${DIR_NEW} && \
                command rm -rf ${DIR} && command mv -f ${DIR_NEW} ${DIR} } 2>&1); then
              _zimfw_print_error "Error updating ${DIR}" ${ERR}
              return 1
            fi
            _zimfw_pull_print_okay Updated 0 ${LOG} || return 1
          else
            _zimfw_pull_print_okay 'Already up to date' || return 1
          fi
        fi
      } always {
        command rm -f ${TARBALL_TARGET} 2>/dev/null
        command rm -rf ${DIR_NEW} 2>/dev/null
      }
      ;;
  esac
  # Check after successful install or update
  if [[ ${SUBMODULES} -ne 0 && -e ${DIR}/.gitmodules ]]; then
    _zimfw_print_warn $'Module contains git submodules, which are not supported by zimfw\'s degit. Use zmodule option \E[1m--no-submodules\E[0;33m to disable this warning.'
  fi
}

_zimfw_tool_git() {
  # This runs in a subshell
  readonly -i SUBMODULES=${5}
  readonly  DIR=${1} URL=${2} TYPE=${3} ONPULL=${6}
  REV=${4}
  case ${_zaction} in
    install)
      if ERR=$(command git clone ${REV:+-b} ${REV} -q --config core.autocrlf=false ${${SUBMODULES:#0}:+--recursive} -- ${URL} ${DIR} 2>&1); then
        _zimfw_pull_print_okay Installed
      else
        _zimfw_print_error 'Error during git clone' ${ERR}
        return 1
      fi
      ;;
    check|update)
      if [[ ! -r ${DIR}/.git ]]; then
        _zimfw_print_warn 'Module was not installed using git. Will not try to '${_zaction}$'. Use zmodule option \E[1m-z\E[0;33m|\E[1m--frozen\E[0;33m to disable this warning.'
        return 0
      fi
      if [[ ${URL} != $(command git -C ${DIR} config --get remote.origin.url) ]]; then
        _zimfw_print_error "The git URL does not match. Expected ${URL}. Will not try to ${_zaction}."
        return 1
      fi
      if ! ERR=$(command git -C ${DIR} fetch -pqt origin 2>&1); then
        _zimfw_print_error 'Error during git fetch' ${ERR}
        return 1
      fi
      if [[ ${TYPE} == branch ]]; then
        if [[ -z ${REV} ]]; then
          # Get HEAD remote branch
          if ! ERR=$(command git -C ${DIR} remote set-head origin -a 2>&1); then
            _zimfw_print_error 'Error during git remote set-head' ${ERR}
            return 1
          fi
          if REV=$(command git -C ${DIR} symbolic-ref --short refs/remotes/origin/HEAD 2>&1); then
            REV=${REV#origin/}
          else
            _zimfw_print_error 'Error during git symbolic-ref' ${REV}
            return 1
          fi
        fi
        TO_REV=${REV}@{u}
        if [[ ${_zaction} == check ]]; then
          readonly -i BEHIND=$(command git -C ${DIR} rev-list --count ${REV}..${TO_REV} -- 2>/dev/null)
          if (( BEHIND )); then
            _zimfw_print_okay "Update available [behind ${BEHIND}]"
            return 4
          else
            _zimfw_print_okay 'Already up to date' 1
            return 0
          fi
        fi
      else
        if [[ ${REV} == $(command git -C ${DIR} describe --tags --exact-match 2>/dev/null) ]]; then
          if [[ ${_zaction} == check ]]; then
            _zimfw_print_okay 'Already up to date' 1
            return 0
          else
            _zimfw_pull_print_okay 'Already up to date'
            return ${?}
          fi
        fi
        if [[ ${_zaction} == check ]]; then
          _zimfw_print_okay 'Update available'
          return 4
        fi
        TO_REV=${REV}
      fi
      LOG=$(command git -C ${DIR} log --graph --color --format='%C(yellow)%h%C(reset) %s %C(cyan)(%cr)%C(reset)' ..${TO_REV} -- 2>/dev/null)
      if ! ERR=$(command git -C ${DIR} checkout -q ${REV} -- 2>&1); then
        _zimfw_print_error 'Error during git checkout' ${ERR}
        return 1
      fi
      if [[ ${TYPE} == branch ]]; then
        if ! OUT=$(command git -C ${DIR} merge --ff-only --no-progress -n 2>&1); then
          _zimfw_print_error 'Error during git merge' ${OUT}
          return 1
        fi
        # keep just first line of OUT
        OUT=${OUT%%($'\n'|$'\r')*}
      else
        OUT="Updating to ${TYPE} ${REV}"
      fi
      if (( SUBMODULES )); then
        if ! ERR=$(command git -C ${DIR} submodule update --init --recursive -q -- 2>&1); then
          _zimfw_print_error 'Error during git submodule update' ${ERR}
          return 1
        fi
      fi
      _zimfw_pull_print_okay ${OUT} 0 ${LOG}
      ;;
  esac
}

_zimfw_tool_mkdir() {
  # This runs in a subshell
  readonly -i SUBMODULES=${5}
  readonly DIR=${1} TYPE=${3} REV=${4} ONPULL=${6}
  if [[ -n ${REV} ]]; then
    _zimfw_print_warn $'The zmodule option \E[1m-'${TYPE[1]}$'\E[0;33m|\E[1m--'${TYPE}$'\E[0;33m has no effect when using the mkdir tool'
  fi
  if (( ! SUBMODULES )); then
    _zimfw_print_warn $'The zmodule option \E[1m--no-submodules\E[0;33m has no effect when using the mkdir tool'
  fi
  if [[ ! -d ${DIR} || -n ${ONPULL} ]]; then
    _zimfw_create_dir ${DIR} && _zimfw_pull_print_okay Created || return 1
  fi
}

_zimfw_run_tool() {
  local -r _zname=${1}
  if [[ -z ${_zurls[${_zname}]} ]]; then
    _zimfw_print_okay 'Skipping external module' 1
    return 0
  fi
  if (( _zfrozens[${_zname}] )); then
    _zimfw_print_okay 'Skipping frozen module' 1
    return 0
  fi
  case ${_zaction} in
    install)
      if [[ -e ${_zdirs[${_zname}]} ]]; then
        _zimfw_print_okay 'Skipping already installed module' 1
        return 0
      fi
      _zimfw_print -nR $'\E[2K\rInstalling '${_zname}' ...'
      ;;
    check|update)
      if [[ ! -d ${_zdirs[${_zname}]} ]]; then
        _zimfw_print_error $'Not installed. Run \E[1mzimfw install\E[0;31m to install.'
        return 1
      fi
      if [[ ${_zaction} == check ]]; then
        if (( _zprintlevel > 1 )) print -nR $'\E[2K\rChecking '${_zname}' ...'
      else
        _zimfw_print -nR $'\E[2K\rUpdating '${_zname}' ...'
      fi
      ;;
    *)
      _zimfw_print_error "Unknown action ${_zaction}"
      return 1
      ;;
  esac
  local -r ztool=${_ztools[${_zname}]}
  case ${ztool} in
    degit|git|mkdir)
      _zimfw_tool_${ztool} "${_zdirs[${_zname}]}" "${_zurls[${_zname}]}" "${_ztypes[${_zname}]}" "${_zrevs[${_zname}]}" "${_zsubmodules[${_zname}]}" "${_zonpulls[${_zname}]}"
      ;;
    *)
      _zimfw_print_error "Unknown tool ${ztool}"
      return 1
      ;;
  esac
}

_zimfw_run_tool_action() {
  local -r _zaction=${1}
  _zimfw_source_zimrc 1 || return 1
  zargs -n 1 -P 0 -- "${_znames[@]}" -- _zimfw_run_tool
  return 0
}

zimfw() {
  builtin emulate -L zsh -o EXTENDED_GLOB
  local -r _zversion='1.14.0' zusage=$'Usage: \E[1m'${0}$'\E[0m <action> [\E[1m-q\E[0m|\E[1m-v\E[0m]

Actions:
  \E[1mbuild\E[0m           Build \E[1m'${ZIM_HOME}$'/init.zsh\E[0m and \E[1m'${ZIM_HOME}$'/login_init.zsh\E[0m.
                  Also does \E[1mcompile\E[0m. Use \E[1m-v\E[0m to also see its output.
  \E[1mclean\E[0m           Clean all. Does both \E[1mclean-compiled\E[0m and \E[1mclean-dumpfile\E[0m.
  \E[1mclean-compiled\E[0m  Clean Zsh compiled files.
  \E[1mclean-dumpfile\E[0m  Clean completion dumpfile.
  \E[1mcompile\E[0m         Compile Zsh files.
  \E[1mhelp\E[0m            Print this help.
  \E[1minfo\E[0m            Print zimfw and system info.
  \E[1mlist\E[0m            List all modules currently defined in \E[1m'${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc}$'\E[0m.
                  Use \E[1m-v\E[0m to also see the modules details.
  \E[1minit\E[0m            Same as \E[1minstall\E[0m, but with output tailored to be used at terminal startup.
  \E[1minstall\E[0m         Install new modules. Also does \E[1mbuild\E[0m, \E[1mcompile\E[0m. Use \E[1m-v\E[0m to also see their
                  output, any on-pull output and skipped modules.
  \E[1muninstall\E[0m       Delete unused modules. Prompts for confirmation. Use \E[1m-q\E[0m for quiet uninstall.
  \E[1mcheck\E[0m           Check if updates for current modules are available. Use \E[1m-v\E[0m to also see
                  skipped and up to date modules.
  \E[1mupdate\E[0m          Update current modules. Also does \E[1mbuild\E[0m, \E[1mcompile\E[0m. Use \E[1m-v\E[0m to also see their
                  output, any on-pull output and skipped modules.
  \E[1mcheck-version\E[0m   Check if a new version of zimfw is available.
  \E[1mupgrade\E[0m         Upgrade zimfw. Also does \E[1mcompile\E[0m. Use \E[1m-v\E[0m to also see its output.
  \E[1mversion\E[0m         Print zimfw version.

Options:
  \E[1m-q\E[0m              Quiet (yes to prompts and only outputs errors)
  \E[1m-v\E[0m              Verbose (outputs more details)'
  local -Ua _znames _zroot_dirs _zdisabled_root_dirs
  local -A _zfrozens _ztools _zdirs _zurls _ztypes _zrevs _zsubmodules _zonpulls _zifs
  local -a _zfpaths _zfunctions _zcmds _zunused_dirs
  local -i _zprintlevel=1
  if (( # > 2 )); then
     print -u2 -lR $'\E[31m'${0}$': Too many options\E[0m' '' ${zusage}
     return 2
  elif (( # > 1 )); then
    case ${2} in
      -q) _zprintlevel=0 ;;
      -v) _zprintlevel=2 ;;
      *)
        print -u2 -lR $'\E[31m'${0}': Unknown option '${2}$'\E[0m' '' ${zusage}
        return 2
        ;;
    esac
  fi

  local -r _zversion_target=${ZIM_HOME}/.latest_version
  if ! zstyle -t ':zim' disable-version-check && \
      [[ ${1} != check-version && -w ${ZIM_HOME} && -w ${__ZIMFW_FILE:A:h} ]]
  then
    # If .latest_version does not exist or was not modified in the last 30 days
    [[ -f ${_zversion_target}(#qNm-30) ]]; local -r zversion_check_force=${?}
    _zimfw_check_version ${zversion_check_force} 1
  fi

  if [[ ! -w ${ZIM_HOME} && ${1} == (build|check|init|install|update|check-version) ]]; then
    print -u2 -R $'\E[31m'${0}$': No write permission to \E[1m'${ZIM_HOME}$'\E[0;31m. Will not try to '${1}$'.\E[0m'
    return 1
  fi
  local _zrestartmsg=' Restart your terminal for changes to take effect.'
  case ${1} in
    build)
      _zimfw_source_zimrc 2 && _zimfw_build || return 1
      (( _zprintlevel-- ))
      _zimfw_compile
      ;;
    check-dumpfile) _zimfw_check_dumpfile ;;
    clean) _zimfw_source_zimrc 2 && _zimfw_clean_compiled && _zimfw_clean_dumpfile ;;
    clean-compiled) _zimfw_source_zimrc 2 && _zimfw_clean_compiled ;;
    clean-dumpfile) _zimfw_clean_dumpfile ;;
    compile) _zimfw_source_zimrc 2 && _zimfw_compile ;;
    help) print -R ${zusage} ;;
    info) _zimfw_info ;;
    list)
      _zimfw_source_zimrc 3 && zargs -n 1 -- "${_znames[@]}" -- _zimfw_run_list && \
          _zimfw_list_unuseds ' (unused)'
      ;;
    check)
      _zrestartmsg=
      _zimfw_run_tool_action ${1} || return 1
      (( _zprintlevel-- ))
      _zimfw_print -R "Done with ${1}." # Only printed in verbose mode
      ;;
    init)
      _zrestartmsg=
      _zimfw_run_tool_action install || return 1
      (( _zprintlevel-- ))
      _zimfw_print 'Done with install.' # Only printed in verbose mode
      _zimfw_source_zimrc 2 && _zimfw_build && _zimfw_compile
      ;;
    install|update)
      _zimfw_run_tool_action ${1} || return 1
      _zimfw_print -R "Done with ${1}.${_zrestartmsg}"
      (( _zprintlevel-- ))
      _zimfw_source_zimrc 2 && _zimfw_build && _zimfw_compile
      ;;
    uninstall) _zimfw_source_zimrc 2 && _zimfw_list_unuseds && _zimfw_uninstall ;;
    check-version) _zimfw_check_version 1 ;;
    upgrade)
      _zimfw_upgrade || return 1
      (( _zprintlevel-- ))
      _zimfw_source_zimrc 2 && _zimfw_compile
      ;;
    version) print -R ${_zversion} ;;
    *)
      print -u2 -lR $'\E[31m'${0}': Unknown action '${1}$'\E[0m' '' ${zusage}
      return 2
      ;;
  esac
}

zimfw "${@}"
