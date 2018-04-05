#
# Configures history options
#

# sets the location of the history file
HISTFILE="${ZDOTDIR:-${HOME}}/.zhistory"

# limit of history entries
HISTSIZE=10000
SAVEHIST=10000

# Perform textual history expansion, csh-style, treating the character ‘!’ specially.
setopt BANG_HIST

# Save each command’s beginning timestamp (in seconds since the epoch) and the duration (in seconds) to the history file.
# ‘: <beginning time>:<elapsed seconds>;<command>’.
setopt EXTENDED_HISTORY

# This options works like APPEND_HISTORY except that new history lines are added to the ${HISTFILE} incrementally
# (as soon as they are entered), rather than waiting until the shell exits.
setopt INC_APPEND_HISTORY

# Shares history across all sessions rather than waiting for a new shell invocation to read the history file.
setopt SHARE_HISTORY

# Do not enter command lines into the history list if they are duplicates of the previous event.
setopt HIST_IGNORE_DUPS

# If a new command line being added to the history list duplicates an older one, 
# the older command is removed from the list (even if it is not the previous event).
setopt HIST_IGNORE_ALL_DUPS

# Remove command lines from the history list when the first character on the line is a space,
# or when one of the expanded aliases contains a leading space.
setopt HIST_IGNORE_SPACE

# When writing out the history file, older commands that duplicate newer ones are omitted.
setopt HIST_SAVE_NO_DUPS

# Whenever the user enters a line with history expansion, don’t execute the line directly;
# instead, perform history expansion and reload the line into the editing buffer.
setopt HIST_VERIFY


# Lists the ten most used commands.
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"
