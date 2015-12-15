#
# generic options and environment settings
#

# use smart URL pasting and escaping
autoload -Uz url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

# Treat single word simple commands without redirection as candidates for resumption of an existing job.
setopt AUTO_RESUME

# List jobs in the long format by default. 
setopt LONG_LIST_JOBS

# Report the status of background jobs immediately, rather than waiting until just before printing a prompt.
setopt NOTIFY

# Run all background jobs at a lower priority. This option is set by default.
unsetopt BG_NICE

# Send the HUP signal to running jobs when the shell exits.
unsetopt HUP

# Report the status of background and suspended jobs before exiting a shell with job control; 
# a second attempt to exit the shell will succeed. 
# NO_CHECK_JOBS is best used only in combination with NO_HUP, else such jobs will be killed automatically
unsetopt CHECK_JOBS
