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

local zpacman_frontend_priv helper

if (( ! ${+zpacman_frontend} )); then
  zpacman_frontend='pacman'
  zpacman_frontend_priv='sudo pacman'
elif (( ! ${+commands[${zpacman_frontend}]} )); then
  print "pacman frontend \"${zpacman_frontend}\" is invalid or not installed. Reverting to \"pacman\".
You can fix this error by editing the 'zpacman_frontend' variable in your .zimrc" >&2
  zpacman_frontend='pacman'
  zpacman_frontend_priv='sudo pacman'
elif [[ ${zpacman_frontend} == ("yaourt"|"pacaur"|"yay"|"pikaur") ]]; then
  # those AUR helpers handle SUID themselves
  zpacman_frontend_priv="${zpacman_frontend}"
else
  zpacman_frontend_priv="sudo ${zpacman_frontend}"
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
alias paci="${zpacman_frontend_priv} -Syu"

# install packages without syncing
alias pacI="${zpacman_frontend_priv} -S"

# install, sync, and upgrade packages (forcibly refresh package lists)
alias pacu="${zpacman_frontend_priv} -Syyu"

# install packages by filename
alias pacU="${zpacman_frontend_priv} -U"

# install all packages in current directory
alias pacd="${zpacman_frontend_priv} -U *.pkg.*"


#
# Remove
#

# remove package and unneeded dependencies
alias pacr="${zpacman_frontend_priv} -R"

# remove package, unneeded dependencies, and configuration files
alias pacrm="${zpacman_frontend_priv} -Rns"


#
# Query
#

# query package information from the remote repository
alias pacq="${zpacman_frontend} -Si"

# query package information from the local repository
alias pacQ="${zpacman_frontend} -Qi"


#
# Search
#

# search for package in the remote repository
alias pacs="${zpacman_frontend} -Ss"

# search for the package in the local repository
alias pacS="${zpacman_frontend} -Qs"


#
# Orphans
#

# list orphan packages
alias pacol="${zpacman_frontend} -Qdt"

# remove orphan packages
alias pacor="${zpacman_frontend_priv} -Rns \$(pacman -Qtdq)"


#
# Ownership
#

# list all files that belong to a package
alias pacown="${zpacman_frontend} -Ql"

# show package(s) owning the specified file
alias pacblame="${zpacman_frontend} -Qo"

#
# Helpers
#

# source helper functions/aliases
for helper in ${zpacman_helper}; do
  if [[ -s ${0:h}/helper_${helper}.zsh ]]; then
    source ${0:h}/helper_${helper}.zsh
  else
    print "no such helper script \"helper_${helper}.zsh\"" >&2
  fi
done
