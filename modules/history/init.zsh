#
# Configures history options
#

# The file to save the history in.
HISTFILE="${ZDOTDIR:-${HOME}}/.zhistory"

# The maximum number of events stored in the internal history list and in the history file.
HISTSIZE=10000
SAVEHIST=10000

# Perform textual history expansion, csh-style, treating the character ‘!’ specially.
setopt BANG_HIST

# This option both imports new commands from the history file, and also causes your
# typed commands to be appended to the history file (like specifying INC_APPEND_HISTORY).
# The history lines are also output with timestamps ala EXTENDED_HISTORY.
setopt SHARE_HISTORY

# Do not enter command lines into the history list if they are duplicates of the previous event.
setopt HIST_IGNORE_DUPS

# If a new command line being added to the history list duplicates an older one,
# the older command is removed from the list (even if it is not the previous event).
setopt HIST_IGNORE_ALL_DUPS

# Remove command lines from the history list when the first character on the
# line is a space, or when one of the expanded aliases contains a leading space.
setopt HIST_IGNORE_SPACE

# When writing out the history file, older commands that duplicate newer ones are omitted.
setopt HIST_SAVE_NO_DUPS

# Whenever the user enters a line with history expansion, don't execute the line directly;
# instead, perform history expansion and reload the line into the editing buffer.
setopt HIST_VERIFY


# Lists the ten most used commands.
alias history-stat="fc -ln 0 | awk '{print \$1}' | sort | uniq -c | sort -nr | head"
