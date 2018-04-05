#
# Directory navigation options
#

#
# Navigation
#

# If a command is issued that can’t be executed as a normal command,
# and the command is the name of a directory, perform the cd command to that directory.
setopt AUTO_CD

# Make cd push the old directory onto the directory stack.
setopt AUTO_PUSHD

# Don’t push multiple copies of the same directory onto the directory stack.
setopt PUSHD_IGNORE_DUPS

# Do not print the directory stack after pushd or popd.
setopt PUSHD_SILENT

# Have pushd with no arguments act like ‘pushd ${HOME}’.
setopt PUSHD_TO_HOME

#
# Globbing and fds
#

# Treat the ‘#’, ‘~’ and ‘^’ characters as part of patterns for filename generation, etc.
# (An initial unquoted ‘~’ always produces named directory expansion.)
setopt EXTENDED_GLOB

# Perform implicit tees or cats when multiple redirections are attempted.
setopt MULTIOS

# Disallow ‘>’ redirection to overwrite existing files.
# ‘>|’ or ‘>!’ must be used to overwrite a file.
setopt NO_CLOBBER
