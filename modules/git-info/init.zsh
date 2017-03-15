# vim: et ts=2 sts=2 sw=2 ft=zsh
#
# Exposes Git repository information via the git_info associative array.
#

# Gets the Git special action (am, bisect, cherry, merge, rebase).
# Borrowed from vcs_info and edited.
_git-action() {
  local git_dir=$(git-dir)
  local action_dir
  for action_dir in \
    "${git_dir}/rebase-apply" \
    "${git_dir}/rebase" \
    "${git_dir}/../.dotest"
  do
    if [[ -d ${action_dir} ]]; then
      local apply_formatted
      local rebase_formatted
      zstyle -s ':zim:git-info:action:apply' format 'apply_formatted' || apply_formatted='apply'
      zstyle -s ':zim:git-info:action:rebase' format 'rebase_formatted' || rebase_formatted='rebase'

      if [[ -f "${action_dir}/rebasing" ]]; then
        print ${rebase_formatted}
      elif [[ -f "${action_dir}/applying" ]]; then
        print ${apply_formatted}
      else
        print "${rebase_formatted}/${apply_formatted}"
      fi

      return 0
    fi
  done

  for action_dir in \
    "${git_dir}/rebase-merge/interactive" \
    "${git_dir}/.dotest-merge/interactive"
  do
    if [[ -f ${action_dir} ]]; then
      local rebase_interactive_formatted
      zstyle -s ':zim:git-info:action:rebase-interactive' format 'rebase_interactive_formatted' || rebase_interactive_formatted='rebase-interactive'
      print ${rebase_interactive_formatted}
      return 0
    fi
  done

  for action_dir in \
    "${git_dir}/rebase-merge" \
    "${git_dir}/.dotest-merge"
  do
    if [[ -d ${action_dir} ]]; then
      local rebase_merge_formatted
      zstyle -s ':zim:git-info:action:rebase-merge' format 'rebase_merge_formatted' || rebase_merge_formatted='rebase-merge'
      print ${rebase_merge_formatted}
      return 0
    fi
  done

  if [[ -f "${git_dir}/MERGE_HEAD" ]]; then
    local merge_formatted
    zstyle -s ':zim:git-info:action:merge' format 'merge_formatted' || merge_formatted='merge'
    print ${merge_formatted}
    return 0
  fi

  if [[ -f "${git_dir}/CHERRY_PICK_HEAD" ]]; then
    if [[ -d "${git_dir}/sequencer" ]]; then
      local cherry_pick_sequence_formatted
      zstyle -s ':zim:git-info:action:cherry-pick-sequence' format 'cherry_pick_sequence_formatted' || cherry_pick_sequence_formatted='cherry-pick-sequence'
      print ${cherry_pick_sequence_formatted}
    else
      local cherry_pick_formatted
      zstyle -s ':zim:git-info:action:cherry-pick' format 'cherry_pick_formatted' || cherry_pick_formatted='cherry-pick'
      print ${cherry_pick_formatted}
    fi

    return 0
  fi

  if [[ -f "${git_dir}/BISECT_LOG" ]]; then
    local bisect_formatted
    zstyle -s ':zim:git-info:action:bisect' format 'bisect_formatted' || bisect_formatted='bisect'
    print ${bisect_formatted}
    return 0
  fi

  return 1
}

# Gets the Git status information.
git-info() {
  # Extended globbing is needed to parse repository status.
  setopt LOCAL_OPTIONS EXTENDED_GLOB

  # Clean up previous git_info.
  unset git_info
  typeset -gA git_info

  # Return if not inside a Git repository work tree.
  if ! is-true $(git rev-parse --is-inside-work-tree 2>/dev/null); then
    return 1
  fi

  if (( $# )); then
    if [[ $1 == [Oo][Nn] ]]; then
      git config --bool prompt.showinfo true
    elif [[ $1 == [Oo][Ff][Ff] ]]; then
      git config --bool prompt.showinfo false
    else
      print "usage: $0 [ on | off ]" >&2
    fi
    return 0
  fi

  # Return if git-info is disabled.
  if ! is-true ${$(git config --bool prompt.showinfo):-true}; then
    return 1
  fi

  # Ignore submodule status.
  local ignore_submodules
  zstyle -s ':zim:git-info' ignore-submodules 'ignore_submodules' || ignore_submodules='all'

  # Format stashed.
  local stashed_format
  local stashed_formatted
  zstyle -s ':zim:git-info:stashed' format 'stashed_format'
  if [[ -n ${stashed_format} && -f "$(git-dir)/refs/stash" ]]; then
    local stashed
    (( stashed=$(git stash list 2>/dev/null | wc -l) ))
    (( stashed )) && zformat -f stashed_formatted ${stashed_format} "S:${stashed}"
  fi

  # Format action.
  local action_format
  local action_formatted
  zstyle -s ':zim:git-info:action' format 'action_format'
  if [[ -n ${action_format} ]]; then
    local action=$(_git-action)
    if [[ -n ${action} ]]; then
      zformat -f action_formatted ${action_format} "s:${action}"
    fi
  fi

  # Get the branch.
  local branch=$(git symbolic-ref -q --short HEAD 2>/dev/null)

  local ahead_formatted
  local behind_formatted
  local branch_formatted
  local commit_formatted
  local diverged_formatted
  local position_formatted
  local remote_formatted
  if [[ -n ${branch} ]]; then
    # Format branch.
    local branch_format
    zstyle -s ':zim:git-info:branch' format 'branch_format'
    if [[ -n ${branch_format} ]]; then
      zformat -f branch_formatted ${branch_format} "b:${branch}"
    fi

    # Format remote.
    local remote_format
    zstyle -s ':zim:git-info:remote' format 'remote_format'
    if [[ -n ${remote_format} ]]; then
      # Gets the remote name.
      local remote_cmd='git rev-parse --symbolic-full-name --verify HEAD@{upstream}'
      local remote=${$(${(z)remote_cmd} 2>/dev/null)##refs/remotes/}
      if [[ -n ${remote} ]]; then
        zformat -f remote_formatted ${remote_format} "R:${remote}"
      fi
    fi

    local ahead_format
    local behind_format
    local diverged_format
    zstyle -s ':zim:git-info:ahead' format 'ahead_format'
    zstyle -s ':zim:git-info:behind' format 'behind_format'
    zstyle -s ':zim:git-info:diverged' format 'diverged_format'
    if [[ -n ${ahead_format} || -n ${behind_format} || -n ${diverged_format} ]]; then
      # Gets the commit difference counts between local and remote.
      local ahead_and_behind_cmd='git rev-list --count --left-right HEAD...@{upstream}'

      # Get ahead and behind counts.
      local ahead_and_behind=$(${(z)ahead_and_behind_cmd} 2>/dev/null)
      local ahead=${ahead_and_behind[(w)1]}
      local behind=${ahead_and_behind[(w)2]}

      if [[ -n ${diverged_format} && ${ahead} -gt 0 && ${behind} -gt 0 ]]; then
        # Format diverged.
        diverged_formatted=${diverged_format}
      else
        # Format ahead.
        if [[ -n ${ahead_format} && ${ahead} -gt 0 ]]; then
          zformat -f ahead_formatted ${ahead_format} "A:${ahead}"
        fi
        # Format behind.
        if [[ -n ${behind_format} && ${behind} -gt 0 ]]; then
          zformat -f behind_formatted ${behind_format} "B:${behind}"
        fi
      fi
    fi
  else
    # Format commit.
    local commit_format
    zstyle -s ':zim:git-info:commit' format 'commit_format'
    if [[ -n ${commit_format} ]]; then
      local commit=$(git rev-parse --short HEAD 2>/dev/null)
      if [[ -n ${commit} ]]; then
        zformat -f commit_formatted ${commit_format} "c:${commit}"
      fi
    fi

    # Format position.
    local position_format
    zstyle -s ':zim:git-info:position' format 'position_format'
    if [[ -n ${position_format} ]]; then
      local position=$(git describe --contains --all HEAD 2>/dev/null)
      if [[ -n ${position} ]]; then
        zformat -f position_formatted ${position_format} "p:${position}"
      fi
    fi
  fi

  # Dirty and clean format.
  local dirty_format
  local dirty_formatted
  local clean_format
  local clean_formatted
  zstyle -s ':zim:git-info:dirty' format 'dirty_format'
  zstyle -s ':zim:git-info:clean' format 'clean_format'

  local dirty
  local indexed
  local indexed_formatted
  local unindexed
  local unindexed_formatted
  local untracked_formatted
  if ! zstyle -t ':zim:git-info' verbose; then
    # Format unindexed.
    local unindexed_format
    zstyle -s ':zim:git-info:unindexed' format 'unindexed_format'
    if [[ -n ${unindexed_format} || -n ${dirty_format} || -n ${clean_format} ]]; then
      (git diff-files --no-ext-diff --quiet --ignore-submodules=${ignore_submodules} 2>/dev/null)
      unindexed=$?
      if (( unindexed )); then
        unindexed_formatted=${unindexed_format}
        dirty=${unindexed}
      fi
    fi

    # Format indexed.
    local indexed_format
    zstyle -s ':zim:git-info:indexed' format 'indexed_format'
    if [[ -n ${indexed_format} || (${dirty} -eq 0 && (-n ${dirty_format} || -n ${clean_format})) ]]; then
      (git diff-index --no-ext-diff --quiet --cached --ignore-submodules=${ignore_submodules} HEAD 2>/dev/null)
      indexed=$?
      if (( indexed )); then
        indexed_formatted=${indexed_format}
        dirty=${indexed}
      fi
    fi

    # Format dirty and clean.
    if (( dirty )); then
      dirty_formatted=${dirty_format}
    else
      clean_formatted=${clean_format}
    fi
  else
    # Use porcelain status for easy parsing.
    local status_cmd="git status --porcelain --ignore-submodules=${ignore_submodules}"

    local untracked
    # Get current status.
    while IFS=$'\n' read line; do
      # T (type change) is undocumented, see http://git.io/FnpMGw.
      if [[ ${line} == \?\?\ * ]]; then
        (( untracked++ ))
      elif [[ ${line} == \ [DMT]\ * ]]; then
        (( unindexed++ ))
      elif [[ ${line} == [ACDMRT]\ \ * ]]; then
        (( indexed++ ))
      elif [[ ${line} == ([ACMRT][DMT]|D[MT])\ * ]]; then
        (( indexed++, unindexed++ ))
      fi
      (( dirty++ ))
    done < <(${(z)status_cmd} 2>/dev/null)

    # Format indexed.
    if (( indexed )); then
      local indexed_format
      zstyle -s ':zim:git-info:indexed' format 'indexed_format'
      zformat -f indexed_formatted ${indexed_format} "i:${indexed}"
    fi

    # Format unindexed.
    if (( unindexed )); then
      local unindexed_format
      zstyle -s ':zim:git-info:unindexed' format 'unindexed_format'
      zformat -f unindexed_formatted ${unindexed_format} "I:${unindexed}"
    fi

    # Format untracked.
    if (( untracked )); then
      local untracked_format
      zstyle -s ':zim:git-info:untracked' format 'untracked_format'
      zformat -f untracked_formatted ${untracked_format} "u:${untracked}"
    fi

    # Format dirty and clean.
    if (( dirty )); then
      zformat -f dirty_formatted ${dirty_format} "u:${dirty}"
    else
      clean_formatted=${clean_format}
    fi
  fi

  # Format info.
  local info_format
  local -A info_formats
  local reply
  zstyle -a ':zim:git-info:keys' format 'info_formats'
  for info_format in ${(k)info_formats}; do
    zformat -f reply "${info_formats[${info_format}]}" \
      "A:${ahead_formatted}" \
      "B:${behind_formatted}" \
      "b:${branch_formatted}" \
      "C:${clean_formatted}" \
      "c:${commit_formatted}" \
      "D:${dirty_formatted}" \
      "i:${indexed_formatted}" \
      "I:${unindexed_formatted}" \
      "p:${position_formatted}" \
      "R:${remote_formatted}" \
      "s:${action_formatted}" \
      "S:${stashed_formatted}" \
      "u:${untracked_formatted}" \
      "V:${diverged_formatted}"
    git_info[${info_format}]=${reply}
  done

  return 0
}
