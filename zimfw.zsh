# AUTOMATICALLY GENERATED FILE. EDIT ONLY THE SOURCE FILES AND THEN COMPILE.
# DO NOT DIRECTLY EDIT THIS FILE!

# MIT License
#
# Copyright (c) 2015-2016 Matt Hamilton and contributors
# Copyright (c) 2016-2025 Eric Nielsen, Matt Hamilton and contributors
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
  print -u2 -R "${_zred}${0}: Error starting zimfw. You're using Zsh version ${_zbold}${ZSH_VERSION}${_znormalred} and versions < ${_zbold}5.2${_znormalred} are not supported. Update your Zsh.${_znormal}"
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
    _zimfw_print -R "${_zokay}${_zbold}${2}:${_znormal} Already up to date"
  else
    if [[ -e ${2} ]]; then
      command mv -f ${2}{,.old} || return 1
    fi
    command mv -f ${1} ${2} && command chmod a+r ${2} && _zimfw_print -R "${_zokay}${_zbold}${2}:${_znormal} Updated.${_zrestartmsg}"
  fi
}

_zimfw_build_init() {
  local -r ztarget=${ZIM_HOME}/init.zsh
  # Force update of init.zsh if it's older than .zimrc
  if [[ ${ztarget} -ot ${_zconfig} ]]; then
    command mv -f ${ztarget}{,.old} || return 1
  fi
  _zimfw_mv =(
    print -R '# FILE AUTOMATICALLY GENERATED FROM '${_zconfig}
    print '# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!'
    print
    print -R 'if [[ -e ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]] zimfw() { source '${${(qqq)__ZIMFW_FILE}/${HOME}/\${HOME}}' "${@}" }'
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
  if [[ ${ztarget} -ot ${_zconfig} ]]; then
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
  local -r zusage="Usage: ${_zbold}${0}${_znormal} <url> [${_zbold}-n${_znormal}|${_zbold}--name${_znormal} <module_name>] [${_zbold}-r${_znormal}|${_zbold}--root${_znormal} <path>] [options]

Add ${_zbold}zmodule${_znormal} calls to your ${_zbold}${_zconfig}${_znormal} file to define the modules to be initialized.
The initialization will be done in the same order it's defined.

  <url>                      Module absolute path or repository URL. The following are equiva-
                             lent: ${_zbold}'foo'${_znormal}, ${_zbold}'zimfw/foo'${_znormal}, ${_zbold}'https://github.com/zimfw/foo.git${_znormal}'.
                             If an absolute path is given, the module is considered externally
                             installed and won't be installed or updated by zimfw.
  ${_zbold}-n${_znormal}, ${_zbold}--name${_znormal} <module_name>   Set a custom module name. Default: the last component in <url>.
                             Slashes can be used inside <module_name> to organize the module
                             into subdirectories. The module will be installed at
                             ${_zbold}${ZIM_HOME}/${_znormal}<module_name>.
  ${_zbold}-r${_znormal}, ${_zbold}--root${_znormal} <path>          Relative path to the module root.

Per-module options:
  ${_zbold}-b${_znormal}, ${_zbold}--branch${_znormal} <branch_name>
                             Use specified branch when installing and updating the module.
                             Overrides the tag option. Default: the repository default branch.
  ${_zbold}-t${_znormal}, ${_zbold}--tag${_znormal} <tag_name>       Use specified tag when installing and updating the module. Over-
                             rides the branch option.
  ${_zbold}-u${_znormal}, ${_zbold}--use${_znormal} <tool_name>      Install and update the module using the defined tool. Default is
                             either defined using ${_zbold}zstyle ':zim:zmodule' use '${_znormal}<tool_name>${_zbold}'${_znormal} or
                             set to ${_zbold}'auto'${_znormal}. The tools available are:
                             ${_zbold}'auto'${_znormal} tries to auto detect the tool to be used. When installing
                             a new module, ${_zbold}'git'${_znormal} will be used if the git command is available,
                             otherwise ${_zbold}'degit'${_znormal} will be used.
                             ${_zbold}'git'${_znormal} uses the git command. Local changes are preserved on up-
                             dates.
                             ${_zbold}'degit'${_znormal} uses curl or wget, and currently only works with GitHub
                             URLs. Modules install faster and take less disk space. Local
                             changes are lost on updates. Git submodules are not supported.
                             ${_zbold}'mkdir'${_znormal} creates an empty directory. The <url> is only used to set
                             the module name. Use the ${_zbold}-c${_znormal}, ${_zbold}--cmd${_znormal} option or ${_zbold}--on-pull${_znormal} option to
                             execute the desired command to generate the module files.
      ${_zbold}--no-submodules${_znormal}        Don't install or update git submodules.
  ${_zbold}-z${_znormal}, ${_zbold}--frozen${_znormal}               Don't install or update the module.

  The per-module options above are carried over multiple zmodule calls for the same module.
  Modules are uniquely identified by their name.

Per-module-root options:
      ${_zbold}--if${_znormal} <test>            Will only initialize module root if specified test returns a zero
                             exit status. The test is evaluated at every new terminal startup.
      ${_zbold}--if-command${_znormal} <cmd_name>
                             Will only initialize module root if specified external command is
                             available. This is evaluated at every new terminal startup.
                             Equivalent to ${_zbold}--if '(( \${+commands[${_znormal}<cmd_name>${_zbold}]} ))'${_znormal}.
      ${_zbold}--if-ostype${_znormal} <ostype>   Will only initialize module root if ${_zbold}OSTYPE${_znormal} is equal to the given
                             expression. This is evaluated at every new terminal startup.
                             Equivalent to ${_zbold}--if '[[ \${OSTYPE} == ${_znormal}<ostype>${_zbold} ]]'${_znormal}.
      ${_zbold}--on-pull${_znormal} <command>    Execute command after installing or updating the module. The com-
                             mand is executed in the module root directory.
  ${_zbold}-d${_znormal}, ${_zbold}--disabled${_znormal}             Don't initialize the module root or uninstall the module.

  The per-module-root options above are carried over multiple zmodule calls for the same mod-
  ule root.

Per-call initialization options:
  ${_zbold}-f${_znormal}, ${_zbold}--fpath${_znormal} <path>         Will add specified path to fpath. The path is relative to the
                             module root directory. Default: ${_zbold}'functions'${_znormal}, if the subdirectory
                             exists and is non-empty.
  ${_zbold}-a${_znormal}, ${_zbold}--autoload${_znormal} <func_name>
                             Will autoload specified function. Default: all valid names inside
                             the ${_zbold}functions${_znormal} subdirectory, if any.
  ${_zbold}-s${_znormal}, ${_zbold}--source${_znormal} <file_path>   Will source specified file. The path is relative to the module
                             root directory. Default: ${_zbold}'init.zsh'${_znormal}, if a non-empty ${_zbold}functions${_znormal}
                             subdirectory exists, else the largest of the files matching the
                             glob ${_zbold}(init.zsh|${_znormal}<name>${_zbold}.(zsh|plugin.zsh|zsh-theme|sh))${_znormal}, if any. The
                             <name> in the glob is resolved to the last component of the mod-
                             ule name and the last component of the path to the module root.
  ${_zbold}-c${_znormal}, ${_zbold}--cmd${_znormal} <command>        Will execute specified command. Occurrences of the ${_zbold}{}${_znormal} placeholder
                             in the command are substituted by the module root directory path.
                             I.e., ${_zbold}-s 'foo.zsh'${_znormal} and ${_zbold}-c 'source {}/foo.zsh'${_znormal} are equivalent.

  Setting any per-call initialization option above will disable the default values from the
  other per-call initialization options, so only your provided values will be used. I.e. these
  values are either all automatic or all manual in each zmodule call. To use default values
  and also provided values, use separate zmodule calls."
  if (( ! # )); then
    print -u2 -lR "${_zerror}${funcfiletrace[1]}: Missing zmodule url${_znormal}" '' ${zusage}
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
      print -u2 -lR "${_zerror}${funcfiletrace[1]}:${_zbold}${zname}:${_znormalred} Missing argument for zmodule option ${_zbold}${1}${_znormal}" '' ${zusage}
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
    print -u2 -lR "${_zerror}${funcfiletrace[1]}:${_zbold}${zname}:${_znormalred} Module already defined with a different URL. Expected ${_zbold}${_zurls[${zname}]}${_znormal}" '' ${zusage}
    _zfailed=1
    return 2
  fi
  _zurls[${zname}]=${zurl}
  local -r zroot_dir=${_zdirs[${zname}]}${zroot:+/${zroot}}
  _zroot_dirs+=(${zroot_dir})
  # Set default values
  if (( ! ${+_ztools[${zname}]} )); then
    zstyle -s ':zim:zmodule' use "_ztools[${zname}]" || _ztools[${zname}]=auto
  fi
  if (( ! ${+_ztypes[${zname}]} )) _ztypes[${zname}]=branch
  if (( ! ${+_zsubmodules[${zname}]} )) _zsubmodules[${zname}]=1
  # Set values from options
  while (( # > 0 )); do
    case ${1} in
      -b|--branch|-t|--tag|-u|--use|--on-pull|--if|--if-command|--if-ostype|-f|--fpath|-a|--autoload|-s|--source|-c|--cmd)
        if (( # < 2 )); then
          print -u2 -lR "${_zerror}${funcfiletrace[1]}:${_zbold}${zname}:${_znormalred} Missing argument for zmodule option ${_zbold}${1}${_znormal}" '' ${zusage}
          _zfailed=1
          return 2
        fi
        ;;
    esac
    case ${1} in
      -b|--branch|-t|--tag|-u|--use|--no-submodules)
        if [[ -z ${zurl} ]] _zimfw_print -u2 -R "${_zwarn}${funcfiletrace[1]}:${_zbold}${zname}:${_znormalyellow} The zmodule option ${_zbold}${1}${_znormalyellow} has no effect for external modules${_znormal}"
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
      --if-ostype)
        shift
        _zifs[${zroot_dir}]="[[ \${OSTYPE} == ${1} ]]"
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
        print -u2 -lR "${_zerror}${funcfiletrace[1]}:${_zbold}${zname}:${_znormalred} Unknown zmodule option ${_zbold}${1}${_znormal}" '' ${zusage}
        _zfailed=1
        return 2
        ;;
    esac
    shift
  done
  # Detect tool if auto and not external and not frozen module
  if [[ ${_ztools[${zname}]} == auto && -n ${_zurls[${zname}]} && _zfrozens[${zname}] -eq 0 ]]; then
    if [[ -e ${_zdirs[${zname}]} ]]; then
      if [[ -r ${_zdirs[${zname}]}/.git ]]; then
        _ztools[${zname}]=git
      elif [[ -r ${_zdirs[${zname}]}/.zdegit ]]; then
        _ztools[${zname}]=degit
      else
        _zimfw_print -u2 -lR "${_zwarn}${funcfiletrace[1]}:${_zbold}${zname}:${_znormalyellow} Could not auto detect tool, will default to ${_zbold}mkdir${_znormalyellow}. Use zmodule option ${_zbold}-u${_znormalyellow}|${_zbold}--use${_znormalyellow} to disable this warning.${_znormal}"
        _ztools[${zname}]=mkdir
      fi
    else
      if [[ ${+commands[git]} -ne 0 && -x ${commands[git]} ]]; then
        _ztools[${zname}]=git
      else
        _ztools[${zname}]=degit
      fi
    fi
  fi
  _znames+=(${zname})
  if (( _zeager )); then
    if [[ ! -e ${zroot_dir} ]]; then
      print -u2 -R "${_zerror}${funcfiletrace[1]}:${_zbold}${zname}: ${zroot_dir}${_znormalred} not found${_znormal}"
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
      _zimfw_print -u2 -lR "${_zwarn}${funcfiletrace[1]}:${_zbold}${zname}:${_znormalyellow} Nothing found to be initialized. Customize the module name, root or initialization with ${_zbold}zmodule${_znormalyellow} options.${_znormal}" '' ${zusage}
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
    local -ri _zeager=${1}
    local -i _zfailed=0
    if ! source ${_zconfig} || (( _zfailed )); then
      print -u2 -R "${_zred}Failed to source ${_zbold}${_zconfig}${_znormal}"
      return 1
    fi
    if (( ${#_znames} == 0 )); then
      print -u2 -R "${_zred}No modules defined in ${_zbold}${_zconfig}${_znormal}"
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
  for zunused (${_zunused_dirs}) _zimfw_print -R "${_zbold}${zunused:t}:${_znormal} ${zunused}${1}"
}

_zimfw_check_dumpfile() {
  _zimfw_print -u2 "${_zyellow}Deprecated action. This is now handled by the completion module alone.${_znormal}"
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
      _zimfw_print -u2 -R "${_zyellow}Latest zimfw version is ${_zbold}${zlatest_version}${_znormalyellow}. You're using version ${_zbold}${_zversion}${_znormalyellow}. Run ${_zbold}zimfw upgrade${_znormalyellow} to upgrade.${_znormal}"
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
      _zimfw_print "Done with clean-compiled. Restart your terminal or run ${_zbold}zimfw compile${_znormal} to re-compile."
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
      _zimfw_print -R "${_zwarn}${_zbold}${zroot_dir}:${_znormalyellow} No write permission, unable to compile.${_znormal}"
      continue
    fi
    for zfile in ${zroot_dir}/(^*test*/)#*.zsh(|-theme)(N-.); do
      if [[ ! ${zfile}.zwc -nt ${zfile} ]]; then
        zcompile -UR ${zfile} && _zimfw_print -R "${_zokay}${_zbold}${zfile}.zwc:${_znormal} Compiled"
      fi
    done
  done
  _zimfw_print 'Done with compile.'
}

_zimfw_info() {
  _zimfw_info_print_symlink ZIM_HOME ${ZIM_HOME}
  _zimfw_info_print_symlink 'zimfw config' ${_zconfig}
  _zimfw_info_print_symlink 'zimfw script' ${__ZIMFW_FILE}
  print -R 'zimfw version:        '${_zversion}' (built at 2025-03-20 20:43:33 UTC, previous commit is 7d0a56b)'
  local zparam
  for zparam in LANG ${(Mk)parameters:#LC_*} OSTYPE TERM TERM_PROGRAM TERM_PROGRAM_VERSION ZSH_VERSION; do
    print -R ${(r.22....:.)zparam}${(P)zparam}
  done
}

_zimfw_info_print_symlink() {
  print -Rn ${(r.22....:.)1}${2}
  if [[ -L ${2} ]] print -Rn ' -> '${2:A}
  print
}

_zimfw_uninstall() {
  if (( _zprintlevel <= 0 )); then
    command rm -rf ${_zunused_dirs} || return 1
  else
    local zunused_dir
    print "Found ${_zbold}${#_zunused_dirs}${_znormal} unused module(s)."
    for zunused_dir in ${_zunused_dirs}; do
      if read -q "?Uninstall ${zunused_dir} [y/N]? "; then
        print
        command rm -rfv ${zunused_dir} || return 1
      else
        print
      fi
    done
    print 'Done with uninstall.'
  fi
}

_zimfw_upgrade() {
  local -r ztarget=${__ZIMFW_FILE:A} zurl=https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh.gz
  if [[ ! -w ${ztarget:h} ]]; then
    print -u2 -R "${_zred}No write permission to ${_zbold}${ztarget:h}${_znormalred}. Will not try to upgrade.${_znormal}"
    return 1
  fi
  {
    if [[ ${+commands[curl]} -ne 0 && -x ${commands[curl]} ]]; then
      command curl -fsSL -o ${ztarget}.new.gz ${zurl} || return 1
    else
      local zopt
      if (( _zprintlevel <= 1 )) zopt=-q
      if ! command wget -nv ${zopt} -O ${ztarget}.new.gz ${zurl}; then
        if (( _zprintlevel <= 1 )); then
          print -u2 -R "${_zred}Failed to download ${_zbold}${zurl}${_znormalred}. Use ${_zbold}-v${_znormalred} option to see details.${_znormal}"
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
  print -nR "${_zbold}${zname}:${_znormal} ${zdir}"
  if [[ ! -e ${zdir} ]] print -n ' (not installed)'
  if [[ -z ${_zurls[${zname}]} ]] print -n ' (external)'
  if (( ${_zfrozens[${zname}]} )) print -n ' (frozen)'
  if (( ${_zdisabled_root_dirs[(I)${zdir}]} )) print -n ' (disabled)'
  print
  if (( _zprintlevel > 1 )); then
    if [[ ${_zfrozens[${zname}]} -eq 0 && -n ${_zurls[${zname}]} ]]; then
      if [[ ${_ztools[${zname}]} == mkdir ]]; then
        print '  From: mkdir'
      else
        print -nR "  From: ${_zurls[${zname}]}, "
        if [[ -z ${_zrevs[${zname}]} ]]; then
          print -n 'default branch'
        else
          print -nR "${_ztypes[${zname}]} ${_zrevs[${zname}]}"
        fi
        print -nR ", using ${_ztools[${zname}]}"
        if (( ! _zsubmodules[${zname}] )) print -n ', no git submodules'
        print
      fi
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
  print -u2 -lR "${_zerror}${_zbold}${_zname}:${_znormalred} ${1}${_znormal}" ${2:+${(F):-  ${(f)^2}}}
}

_zimfw_print_okay() {
  if (( _zprintlevel > ${2:-0} )) print -lR "${_zokay}${_zbold}${_zname}:${_znormal} ${1}" ${3:+${(F):-  ${(f)^3}}}
}

_zimfw_print_warn() {
  _zimfw_print -u2 -R "${_zwarn}${_zbold}${_zname}:${_znormalyellow} ${1}${_znormal}"
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
    _zimfw_print_error "${URL} is not a valid URL. Will not try to ${ACTION}. The zimfw degit tool only supports GitHub URLs. Use zmodule option ${_zbold}--use git${_znormalred} to use git instead."
    return 1
  fi
  readonly HEADERS_TARGET=${DIR}/${TEMP}_headers
  {
    if [[ ${ACTION} != install ]]; then
      readonly INFO=("${(@f)"$(<${INFO_TARGET})"}")
      # Previous REV is in line 2, reserved for future use.
      readonly INFO_HEADER=${INFO[3]}
    fi
    readonly TARBALL_URL=https://api.github.com/repos/${REPO}/tarball/${REV}
    if [[ ${ACTION} == check ]]; then
      if [[ -z ${INFO_HEADER} ]] return 0
      if [[ ${+commands[curl]} -ne 0 && -x ${commands[curl]} ]]; then
        command curl -IfsL -H ${INFO_HEADER} ${TARBALL_URL} >${HEADERS_TARGET}
      else
        command wget --spider -qS --header=${INFO_HEADER} ${TARBALL_URL} 2>${HEADERS_TARGET}
      fi
    else
      if [[ ${+commands[curl]} -ne 0 && -x ${commands[curl]} ]]; then
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
    if [[ ${ACTION} == check ]]; then
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
  readonly -i SUBMODULES=${6}
  readonly ACTION=${1} DIR=${2} URL=${3} REV=${5} ONPULL=${7} TEMP=.zdegit_${sysparams[pid]}_${RANDOM}
  readonly TARBALL_TARGET=${DIR}/${TEMP}_tarball.tar.gz INFO_TARGET=${DIR}/.zdegit
  case ${ACTION} in
    pre|prereinstall)
      local premsg
      if [[ ${ACTION} == pre ]] premsg=" Use zmodule option ${_zbold}-z${_znormalred}|${_zbold}--frozen${_znormalred} to disable this error or run ${_zbold}zimfw reinstall${_znormalred} to reinstall."
      if [[ -e ${DIR} ]]; then
        if [[ ! -r ${INFO_TARGET} ]]; then
          _zimfw_print_error $'Module was not installed using zimfw\'s degit.'${premsg}
          return 1
        fi
        readonly INFO=("${(@f)"$(<${INFO_TARGET})"}")
        if [[ ${URL} != ${INFO[1]} ]]; then
          _zimfw_print_error 'The zimfw degit URL does not match. Expected '${URL}.${premsg}
          return 1
        fi
      fi
      return 0
      ;;
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
      readonly DIR_NEW=${DIR}${TEMP}
      {
        _zimfw_download_tarball || return 1
        if [[ ${ACTION} == check ]]; then
          if [[ -e ${TARBALL_TARGET} ]]; then
            _zimfw_print_okay 'Update available'
            return 4
          fi
          _zimfw_print_okay 'Already up to date' 1
          return 0
        else
          if [[ -e ${TARBALL_TARGET} ]]; then
            _zimfw_create_dir ${DIR_NEW} && _zimfw_untar_tarball ${DIR_NEW} || return 1
            if [[ ${+commands[diff]} -ne 0 && -x ${commands[diff]} ]]; then
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
    _zimfw_print_warn "Module contains git submodules, which are not supported by zimfw's degit. Use zmodule option ${_zbold}--no-submodules${_znormalyellow} to disable this warning."
  fi
}

_zimfw_tool_git() {
  # This runs in a subshell
  readonly -i SUBMODULES=${6}
  readonly ACTION=${1} DIR=${2} URL=${3} TYPE=${4} ONPULL=${7}
  REV=${5}
  case ${ACTION} in
    pre|prereinstall)
      local premsg
      if [[ ${ACTION} == pre ]] premsg=" Use zmodule option ${_zbold}-z${_znormalred}|${_zbold}--frozen${_znormalred} to disable this error or run ${_zbold}zimfw reinstall${_znormalred} to reinstall."
      if [[ -e ${DIR} ]]; then
        if [[ ! -r ${DIR}/.git ]]; then
          _zimfw_print_error 'Module was not installed using git.'${premsg}
          return 1
        fi
        if [[ ${URL} != $(command git -C ${DIR} config --get remote.origin.url) ]]; then
          _zimfw_print_error 'The git URL does not match. Expected '${URL}.${premsg}
          return 1
        fi
      fi
      ;;
    install)
      if ERR=$(command git clone ${REV:+-b} ${REV} -q --config core.autocrlf=false ${${SUBMODULES:#0}:+--recursive} -- ${URL} ${DIR} 2>&1); then
        _zimfw_pull_print_okay Installed
      else
        _zimfw_print_error 'Error during git clone' ${ERR}
        return 1
      fi
      ;;
    check|update)
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
        if [[ ${ACTION} == check ]]; then
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
          if [[ ${ACTION} == check ]]; then
            _zimfw_print_okay 'Already up to date' 1
            return 0
          else
            _zimfw_pull_print_okay 'Already up to date'
            return ${?}
          fi
        fi
        if [[ ${ACTION} == check ]]; then
          _zimfw_print_okay 'Update available'
          return 4
        fi
        TO_REV=${REV}
      fi
      if [[ -z ${NO_COLOR} && -t 1 ]]; then
        LOG=$(command git -C ${DIR} log --graph --color --format='%C(yellow)%h%C(reset) %s %C(cyan)(%cr)%C(reset)' ..${TO_REV} -- 2>/dev/null)
      else
        LOG=$(command git -C ${DIR} log --graph --format='%h %s (%cr)' ..${TO_REV} -- 2>/dev/null)
      fi
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
  readonly -i SUBMODULES=${6}
  readonly ACTION=${1} DIR=${2} TYPE=${4} REV=${5} ONPULL=${7}
  if [[ ${ACTION} == (pre|prereinstall|check) ]] return 0
  if [[ -n ${REV} ]]; then
    _zimfw_print_warn "The zmodule option ${_zbold}-${TYPE[1]}${_znormalyellow}|${_zbold}--${TYPE}${_znormalyellow} has no effect when using the mkdir tool"
  fi
  if (( ! SUBMODULES )); then
    _zimfw_print_warn "The zmodule option ${_zbold}--no-submodules${_znormalyellow} has no effect when using the mkdir tool"
  fi
  if [[ ! -d ${DIR} || -n ${ONPULL} ]]; then
    _zimfw_create_dir ${DIR} && _zimfw_pull_print_okay Created || return 1
  fi
}

_zimfw_run_tool() {
  local zaction=${1}
  local -r _zname=${2}
  if [[ -z ${_zurls[${_zname}]} ]]; then
    _zimfw_print_okay 'Skipping external module' 1
    return 0
  fi
  if (( _zfrozens[${_zname}] )); then
    _zimfw_print_okay 'Skipping frozen module' 1
    return 0
  fi
  local -r ztool=${_ztools[${_zname}]}
  if [[ ${ztool} != (degit|git|mkdir) ]]; then
    _zimfw_print_error "Unknown tool ${ztool}"
    return 1
  fi
  set "${_zdirs[${_zname}]}" "${_zurls[${_zname}]}" "${_ztypes[${_zname}]}" "${_zrevs[${_zname}]}" "${_zsubmodules[${_zname}]}" "${_zonpulls[${_zname}]}"
  if [[ ${zaction} == reinstall ]]; then
    _zimfw_tool_${ztool} prereinstall "${@}" && return 0
    if (( _zprintlevel > 0 )); then
      if read -q "?Reinstall ${_zname} [y/N]? "; then
        print
      else
        print
        return 0
      fi
    fi
    local -r zdir_new=.${_zdirs[${_zname}]}_${sysparams[pid]}_${RANDOM}
    {
      _zimfw_tool_${ztool} install ${zdir_new} "${@:2}" || return 1
      if ! ERR=$({ command rm -rf ${_zdirs[${_zname}]} && command mv -f ${zdir_new} ${_zdirs[${_zname}]} } 2>&1); then
        _zimfw_print_error "Error reinstalling ${_zdirs[${_zname}]}" ${ERR}
        return 1
      fi
    } always {
      command rm -rf ${zdir_new} 2>/dev/null
    }
    return 0
  else
    _zimfw_tool_${ztool} pre "${@}" || return 1
  fi
  case ${zaction} in
    install)
      if [[ -e ${_zdirs[${_zname}]} ]]; then
        _zimfw_print_okay 'Skipping already installed module' 1
        return 0
      fi
      ;;
    check|update)
      if [[ ! -d ${_zdirs[${_zname}]} ]]; then
        _zimfw_print_error "Not installed. Run ${_zbold}zimfw install${_znormalred} to install."
        return 1
      fi
      ;;
    *)
      _zimfw_print_error "Unknown action ${zaction}"
      return 1
      ;;
  esac
  _zimfw_tool_${ztool} ${zaction} "${@}"
}

_zimfw_run_tool_action() {
  local -i zmaxprocs=0
  if [[ ${1} == reinstall ]] zmaxprocs=1
  _zimfw_source_zimrc 0 || return 1
  zargs -n 2 -P ${zmaxprocs} -- "${_znames[@]}" -- _zimfw_run_tool ${1}
  return 0
}

zimfw() {
  builtin emulate -L zsh -o EXTENDED_GLOB
  if [[ -z ${NO_COLOR} && -t 1 ]]; then
    local -r _znormal=$'\E[0m' _zbold=$'\E[1m' _zred=$'\E[31m' _znormalred=$'\E[0;31m' _zgreen=$'\E[32m' _zyellow=$'\E[33m' _znormalyellow=$'\E[0;33m'
  else
    local -r _znormal= _zbold= _zred= _znormalred= _zgreen= _zyellow= _znormalyellow=
  fi
  local -r _zerror="${_zred}x " _zokay="${_zgreen}) ${_znormal}" _zwarn="${_zyellow}! "
  local -r _zconfig=${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} _zversion='1.18.0'
  local -r zusage="Usage: ${_zbold}${0}${_znormal} <action> [option]

Actions:
  ${_zbold}build${_znormal}               Build ${_zbold}${ZIM_HOME}/init.zsh${_znormal} and ${_zbold}${ZIM_HOME}/login_init.zsh${_znormal}.
                      Also does ${_zbold}compile${_znormal}. Use ${_zbold}-v${_znormal} to also see its output.
  ${_zbold}clean${_znormal}               Clean all. Does both ${_zbold}clean-compiled${_znormal} and ${_zbold}clean-dumpfile${_znormal}.
  ${_zbold}clean-compiled${_znormal}      Clean Zsh compiled files.
  ${_zbold}clean-dumpfile${_znormal}      Clean completion dumpfile.
  ${_zbold}compile${_znormal}             Compile Zsh files.
  ${_zbold}info${_znormal}                Print zimfw and system info.
  ${_zbold}list${_znormal}                List all modules defined in ${_zbold}${_zconfig}${_znormal}.
                      Use ${_zbold}-v${_znormal} to also see their initialization details.
  ${_zbold}init${_znormal}                Same as ${_zbold}install${_znormal}, but with output tailored for the terminal startup.
  ${_zbold}install${_znormal}             Install new modules. Also does ${_zbold}build${_znormal}, ${_zbold}compile${_znormal}. Use ${_zbold}-v${_znormal} to also see their
                      output, any on-pull output and skipped modules.
  ${_zbold}reinstall${_znormal}           Reinstall modules that failed check. Prompts for confirmation, unless ${_zbold}-q${_znormal}
                      is used. Also does ${_zbold}build${_znormal}, ${_zbold}compile${_znormal}. Use ${_zbold}-v${_znormal} to also see their output, any
                      on-pull output and skipped modules.
  ${_zbold}uninstall${_znormal}           Delete unused modules. Prompts for confirmation, unless ${_zbold}-q${_znormal} is used.
  ${_zbold}check${_znormal}               Check if updates for current modules are available. Use ${_zbold}-v${_znormal} to also see
                      skipped and up to date modules.
  ${_zbold}update${_znormal}              Update current modules. Also does ${_zbold}build${_znormal}, ${_zbold}compile${_znormal}. Use ${_zbold}-v${_znormal} to also see
                      their output, any on-pull output and skipped modules.
  ${_zbold}check-version${_znormal}       Check if a new version of zimfw is available.
  ${_zbold}upgrade${_znormal}             Upgrade zimfw. Also does ${_zbold}compile${_znormal}. Use ${_zbold}-v${_znormal} to also see its output.
  ${_zbold}help${_znormal},    ${_zbold}--help${_znormal}     Print this help.
  ${_zbold}version${_znormal}, ${_zbold}--version${_znormal}  Print zimfw version.

Options:
  ${_zbold}-q${_znormal}                  Quiet (yes to prompts and only outputs errors)
  ${_zbold}-v${_znormal}                  Verbose (outputs more details)"
  local -i _zprintlevel=1
  if (( # > 2 )); then
     print -u2 -lR "${_zred}${0}: Too many options${_znormal}" '' ${zusage}
     return 2
  elif (( # > 1 )); then
    case ${2} in
      -q) _zprintlevel=0 ;;
      -v) _zprintlevel=2 ;;
      *)
        print -u2 -lR "${_zred}${0}: Unknown option ${2}${_znormal}" '' ${zusage}
        return 2
        ;;
    esac
  fi
  case ${1} in
    help|--help)
      print -R ${zusage}
      return
      ;;
    version|--version)
      print -R ${_zversion}
      return
      ;;
  esac

  if (( ! ${+ZIM_HOME} )); then
    print -u2 -R "${_zred}${0}: ${_zbold}ZIM_HOME${_znormalred} not defined${_znormal}"
    return 1
  fi
  if [[ ! -e ${ZIM_HOME} ]]; then
    command mkdir -p ${ZIM_HOME} || return 1
  fi

  local -r _zversion_target=${ZIM_HOME}/.latest_version
  if ! zstyle -t ':zim' disable-version-check && \
      [[ ${1} != check-version && -w ${ZIM_HOME} && -w ${__ZIMFW_FILE:A:h} ]]
  then
    # If .latest_version does not exist or was not modified in the last 30 days
    [[ -f ${_zversion_target}(#qNm-30) ]]; local -r zversion_check_force=${?}
    _zimfw_check_version ${zversion_check_force} 1
  fi

  if [[ ! -w ${ZIM_HOME} && ${1} == (build|check|init|install|update|reinstall|check-version) ]]; then
    print -u2 -R "${_zred}${0}: No write permission to ${_zbold}${ZIM_HOME}${_znormalred}. Will not try to ${1}.${_znormal}"
    return 1
  fi
  local -Ua _znames _zroot_dirs _zdisabled_root_dirs
  local -A _zfrozens _ztools _zdirs _zurls _ztypes _zrevs _zsubmodules _zonpulls _zifs
  local -a _zfpaths _zfunctions _zcmds _zunused_dirs
  local _zrestartmsg=' Restart your terminal for changes to take effect.'
  autoload -Uz zargs
  case ${1} in
    build)
      _zimfw_source_zimrc 1 && _zimfw_build || return 1
      (( _zprintlevel-- ))
      _zimfw_compile
      ;;
    check-dumpfile) _zimfw_check_dumpfile ;;
    clean) _zimfw_source_zimrc 0 && _zimfw_clean_compiled && _zimfw_clean_dumpfile ;;
    clean-compiled) _zimfw_source_zimrc 0 && _zimfw_clean_compiled ;;
    clean-dumpfile) _zimfw_clean_dumpfile ;;
    compile) _zimfw_source_zimrc 0 && _zimfw_compile ;;
    info) _zimfw_info ;;
    list)
      _zimfw_source_zimrc $(( _zprintlevel > 1 )) && \
          zargs -n 1 -- "${_znames[@]}" -- _zimfw_run_list && \
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
      _zimfw_source_zimrc 1 && _zimfw_build && _zimfw_compile
      ;;
    install|update|reinstall)
      _zimfw_run_tool_action ${1} || return 1
      _zimfw_print -R "Done with ${1}.${_zrestartmsg}"
      (( _zprintlevel-- ))
      _zimfw_source_zimrc 1 && _zimfw_build && _zimfw_compile
      ;;
    uninstall) _zimfw_source_zimrc 0 && _zimfw_list_unuseds && _zimfw_uninstall ;;
    check-version) _zimfw_check_version 1 ;;
    upgrade)
      _zimfw_upgrade || return 1
      (( _zprintlevel-- ))
      _zimfw_source_zimrc 0 && _zimfw_compile
      ;;
    *)
      print -u2 -lR "${_zred}${0}: Unknown action ${1}${_znormal}" '' ${zusage}
      return 2
      ;;
  esac
}

zimfw "${@}"
