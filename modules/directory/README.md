directory
=========

Sets directory, navigation, and redirect options.

zsh options
-----------

  * `AUTO_CD` performs cd to a directory if the typed command is invalid, but is a directory.
  * `AUTO_PUSHD` makes cd push the old directory to the directory stack.
  * `PUSHD_IGNORE_DUPS` does not push multiple copies of the same directory to the stack.
  * `PUSHD_SILENT` does not print the directory stack after pushd or popd.
  * `PUSHD_TO_HOME` has pushd without arguments act like `pushd ${HOME}`.
  * `EXTENDED_GLOB` treats `#`, `~`, and `^` as patterns for filename globbing.
  * `MULTIOS` performs implicit tees or cats when using multiple redirections.
  * `NO_CLOBBER` disallows `>` to overwrite existing files. Use `>|` or `>!` instead.
