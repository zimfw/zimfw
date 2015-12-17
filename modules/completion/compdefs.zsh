#
# Alias compdefs
#

# Any aliased commands will not function with completion without compdefs.
# Because completion is the LAST module to be loaded (so we make sure to catch all completions)
# we must assign the compdefs here, as opposed to within the modules themselves.

# Unfortunately, I'm not aware of a worthwhile way to ensure that these will be included in .zcompdump

# zpacman_frontend -> pacman
if (( ${+zpacman_frontend} )); then
  compdef ${zpacman_frontend}='pacman'
fi
