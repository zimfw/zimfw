Directory
=========

Sets directory, navigation, and redirect options.

ZSH options
-----------

| Option | Effect |
| ------ | ----------- |
| AUTO_CD | If the typed command is invalid, but is a directory, cd to that directory |
| AUTO_PUSHD | After cd, push the old directory to the directory stack |
| PUSHD_IGNORE_DUPS | Don't push multiple copies of the same directory to the stack |
| PUSHD_SILENT | Don't print the directory after pushd or popd |
| PUSHD_TO_HOME | pushd without arguments acts like `pushd ${HOME}` |
| EXTENDED_GLOB | Treat `#`, `~`, and `^` as patterns for filename globbing |
| MULTIOS | Performs implicit tees or cats when using redirections |
| NO_CLOBBER | Disables overwrite existing files with `>`. Use `>|` or `>!` instead |
