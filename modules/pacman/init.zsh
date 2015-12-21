#
# Pacman aliases
#

# ${zpacman_frontend} is provided by either .zimrc or (if not set) init.zsh
# The zpacman_frontend is _only_ used for package installs.

#
# Setup
#

# ensure pacman is available
if (( ! ${+commands[pacman]} )); then
  return 1
fi

# find if there is a pacman wrapper available (and not set in .zimrc)
if [[ ${zpacman_frontend} == 'auto' ]]; then
  # no frontend set in config; test for common frontends.

  if (( ${+commands[powerpill]} )); then
    zpacman_frontend='powerpill'
  elif (( ${+commands[pacmatic]} )); then
    zpacman_frontend='pacmatic'
  else
    zpacman_frontend='pacman'
  fi
elif (( ! ${+zpacman_frontend} )); then
  zpacman_frontend='pacman'
elif (( ! ${+commands[${zpacman_frontend}]} )); then
  print "pacman frontend \"${zpacman_frontend}\" is invalid or not installed. Reverting to \"pacman\"." >&2 
  print "you can fix this error by editing the 'zpacman_frontend' variable in your .zimrc" >&2 
  zpacman_frontend='pacman'
fi

#
# General
#

alias pac=${zpacman_frontend}

#
# Build
#

# build package in current directory, cleanup, and install
alias pacb='makepkg -sci'

#
# Install
#

#NOTE: Installing/upgrading individual packages is NOT supported. Sync and upgrade ALL on install.

# install, sync, and upgrade packages
alias paci='sudo ${zpacman_frontend} -Syu'

# install, sync, and upgrade packages (forcibly refresh package lists)
alias pacu='sudo ${zpacman_frontend} -Syyu'

# install packages by filename
alias pacU='sudo ${zpacman_frontend} -U'

# install all packages in current directory
alias pacd='sudo ${zpacman_frontend} -U *.pkg.tar.xz'


#
# Remove
#

# remove package and unneeded dependencies
alias pacr='sudo pacman -R'

# remove package, unneeded dependencies, and configuration files
alias pacrm='sudo pacman -Rns'


#
# Query
#

# query package information from the remote repository
alias pacq='pacman -Si'

# query package information from the local repository
alias pacQ='pacman -Qi'


#
# Search
#

# search for package in the remote repository
alias pacs='pacman -Ss'

# search for the package in the local repository
alias pacS='pacman -Qs'


#
# Orphans
#

# list orphan packages
alias pacol='pacman -Qdt'

# remove orphan packages
alias pacor='sudo pacman -Rns $(pacman -Qtdq)'


#
# Ownership
#

# list all files that belong to a package
alias pacown='pacman -Ql'

# show package(s) owning the specified file
alias pacblame='pacman -Qo'

#
# Helpers
#

# source helper functions/aliases
for helper ( ${zpacman_helper[@]} ); do
  if [[ -s ${0:h}/helper_${helper}.zsh ]]; then
    source ${0:h}/helper_${helper}.zsh
  else
    print "no such helper script \"helper_${helper}.zsh\"" >&2
  fi
done

