history
=======

Sets sane history options.

The history is set to be saved in the `${ZDOTDIR:-${HOME}}/.zhistory` file.

Zsh options
-----------

  * `BANG_HIST` performs csh-style '!' expansion.
  * `SHARE_HISTORY` causes all terminals to share the same history 'session'.
  * `HIST_IGNORE_DUPS` does not enter immediate duplicates into the history.
  * `HIST_IGNORE_ALL_DUPS` removes older command from the history if a duplicate is to be added.
  * `HIST_IGNORE_SPACE` removes commands from the history that begin with a space.
  * `HIST_SAVE_NO_DUPS` ommits older commands that duplicate newer ones when saving.
  * `HIST_VERIFY` doesn't execute the command directly upon history expansion.

Aliases
-------

  * `history-stat` lists the 10 most used commands
