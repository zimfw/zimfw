#
# Pacman aliases and functions
#

# ensure pacman is available
if (( ! $+commands[pacman] )); then
  return 1
fi

# find if there is a pacman wrapper available (and not set in .zimrc)
if [[ ${zpacman_frontend} == 'auto' ]]; then
  # no frontend set in config; test for common frontends.

  if (( $+commands[powerpill] )); then
    zpacman_frontend='powerpill'
  elif (( $+commands[pacmatic] )); then
    zpacman_frontend='pacmatic'
  else
    zpacman_frontend='pacman'
  fi
elif (( ! $+zpacman_frontend )); then
  zpacman_frontend='pacman'
elif (( ! $+commands[${zpacman_frontend}] )); then
  print "pacman frontend \"${zpacman_frontend}\" is invalid or not installed. Reverting to \"pacman\"." >&2 
  print "you can fix this error by editing the 'zpacman_frontend' variable in your .zimrc" >&2 
  zpacman_frontend='pacman'
fi

# source helper functions/aliases
for helper ( ${zpacman_helper[@]} ); do
  if [[ -s ${0:h}/helper_${helper}.zsh ]]; then
    source ${0:h}/helper_${helper}.zsh
  else
    print "no such helper script \"helper_${helper}.zsh\"" >&2
  fi
done

# source pacman aliases
source ${0:h}/alias.zsh
