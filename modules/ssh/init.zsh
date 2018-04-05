#
# sets up ssh-agent
#

# don't do anything unless we can actually use ssh-agent
if (( ! ${+commands[ssh-agent]} )); then
  return 1
fi

# use a sane temp dir; creating 1k ssh-* files in /tmp is crazy
if [[ ${TMPDIR} ]]; then
  local ssh_env=${TMPDIR}/ssh-agent.env
  local ssh_sock=${TMPDIR}/ssh-agent.sock
else
  # create a sane tmp dir at /tmp/username
  mkdir -p /tmp/${USER}
  local ssh_env=/tmp/${USER}/ssh-agent.env
  local ssh_sock=/tmp/${USER}/ssh-agent.sock
fi

# start ssh-agent if not already running
if [[ ! -S ${SSH_AUTH_SOCK} ]]; then
  # read environment if possible
  source ${ssh_env} 2> /dev/null

  if ! ps -U ${LOGNAME} -o pid,ucomm | grep -q -- "${SSH_AGENT_PID:--1} ssh-agent"; then
    eval "$(ssh-agent | sed '/^echo /d' | tee ${ssh_env})"
  fi
fi

# create socket
if [[ -S ${SSH_AUTH_SOCKET} && ${SSH_AUTH_SOCKET} != ${ssh_sock} ]]; then
  ln -sf ${SSH_AUTH_SOCKET} ${ssh_sock}
  export SSH_AUTH_SOCK=${ssh_sock}
fi

# load ids
if ssh-add -l 2>&1 | grep -q 'no identities'; then
  if (( ${#zssh_ids} > 0 )); then
    ssh-add "${HOME}/.ssh/${^zssh_ids[@]}" 2> /dev/null
  else
    ssh-add 2> /dev/null
  fi
fi

unset ssh_{sock,env}
