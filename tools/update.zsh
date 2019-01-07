# This runs in a new shell
URL=${1}
DIR=${2}
TYPE=${3}
REV=${4}
OPT=${5}
MODULE=${DIR:t}
if ! cd ${DIR} 2>/dev/null; then
  print -P "%F{red}✗ ${MODULE}: Not installed%f"
  return 1
fi
if ! command git rev-parse --is-inside-work-tree &>/dev/null; then
  # Not a git repository. Will not try to update.
  return 0
fi
if [[ ${URL} != $(command git config --get remote.origin.url) ]]; then
  print -P "%F{red}✗ ${MODULE}: URL does not match. Expected ${URL}. Will not try to update.%f"
  return 1
fi
if [[ ${TYPE} == 'tag' ]]; then
  if [[ ${REV} == $(command git describe --tags --exact-match 2>/dev/null) ]]; then
    [[ ${OPT} != -q ]] && print -P "%F{green}✓%f ${MODULE}: Already up to date"
    return 0
  fi
fi
if ! ERR=$(command git fetch -pq origin ${REV} 2>&1); then
  print -P "%F{red}✗ ${MODULE}: Error (1)%f\n${ERR}"
  return 1
fi
if [[ ${TYPE} == 'branch' ]]; then
  LOG_REV="${REV}@{u}"
else
  LOG_REV=${REV}
fi
LOG=$(command git log --graph --color --format='%C(yellow)%h%C(reset) %s %C(cyan)(%cr)%C(reset)' ..${LOG_REV} 2>/dev/null)
if ! ERR=$(command git checkout -q ${REV} -- 2>&1); then
  print -P "%F{red}✗ ${MODULE}: Error (2)%f\n${ERR}"
  return 1
fi
if [[ ${TYPE} == 'branch' ]]; then
  if ! OUT=$(command git merge --ff-only --no-progress -n 2>&1); then
    print -P "%F{red}✗ ${MODULE}: Error (3)%f\n${OUT}"
    return 1
  fi
  # keep just first line of OUT
  OUT=${OUT%%($'\n'|$'\r')*}
else
  OUT="Updating to ${TYPE} ${REV}"
fi
[[ -n ${LOG} ]] && OUT="${OUT}\n${LOG}"
if ERR=$(command git submodule update --init --recursive -q 2>&1); then
  if [[ ${OPT} != -q ]]; then
    print -P "%F{green}✓%f ${MODULE}: ${OUT}"
  fi
else
  print -P "%F{red}✗ ${MODULE}: Error (4)%f\n${ERR}"
  return 1
fi
