History
=======

Sets sane default history options.

History file is set to save in `${ZDOTDIR:-${HOME}}/.zhistory`

(most likely ~/.zhistory)

Zsh Options
-----------

| Option | Effect |
| ------ | ------ |
| BANG_HIST | Use csh-style '!' expansion |
| EXTENDED_HISTORY | Save timestamps along with commands |
| INC_APPEND_HISTORY | Commands are added to the history file immediately upon execution |
| SHARE_HISTORY | Causes all terminals to share the same history 'session' |
| HIST_IGNORE_DUPS | Do not enter immediate duplicates into history |
| HIST_IGNORE_ALL_DUPS | If duplicate is to be added, remove older instance in history |
| HIST_IGNORE_SPACE | Do not add any commands to history that begin with a space |
| HIST_SAVE_NO_DUPS | When saving, older commands that duplicate newer commands are omitted |
| HIST_VERIFY | Upon history 'selection', don't execute immediately. Require a carriage return |

Aliases
-------

  * `history-stat` lists the 10 most used commands
