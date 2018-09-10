#
# sets up ssh-agent
#

# don't do anything unless we can actually use ssh-agent
if (( ! ${+commands[ssh-agent]} )); then
  return 1
fi

ssh-add -l &>/dev/null
if (( ? == 2 )); then
  # Unable to contact the authentication agent

  # Load stored agent connection info
  local ssh_env="${HOME}/.ssh-agent"
  [[ -r ${ssh_env} ]] && source ${ssh_env} >/dev/null

  ssh-add -l &>/dev/null
  if (( ? == 2 )); then
      # Start agent and store agent connection info
      (umask 066; ssh-agent >! ${ssh_env})
      source ${ssh_env} >/dev/null
  fi
fi

# Load identities
ssh-add -l &>/dev/null
if (( ? == 1 )); then
  if (( ${#zssh_ids} > 0 )); then
    ssh-add "${HOME}/.ssh/${^zssh_ids[@]}" 2> /dev/null
  else
    ssh-add 2> /dev/null
  fi
fi
