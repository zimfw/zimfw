# This runs in a new shell
URL=${1}
DIR=${2}
REV=${4}
OPT=${5}
MODULE=${DIR:t}
if [[ -e ${DIR} ]]; then
  # Already exists
  return 0
fi
if ERR=$(command git clone -b ${REV} -q --recursive ${URL} ${DIR} 2>&1); then
  if [[ ${OPT} != -q ]]; then
    print -P "%F{green}✓%f ${MODULE}: Installed"
  fi
else
  print -P "%F{red}✗ ${MODULE}: Error%f\n${ERR}"
  return 1
fi
