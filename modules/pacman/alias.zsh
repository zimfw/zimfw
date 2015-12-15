#
# Pacman aliases
#

# ${zpacman_frontend} is provided by either .zimrc or (if not set) init.zsh
# The zpacman_frontend is _only_ used for package installs.

#
# General
#

alias pacman=${zpacman_frontend}
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
