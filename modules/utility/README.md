Utility
=======

Utility aliases and functions.

Adds colour to `ls`, `grep` and `less`.

Aliases
-------

### ls

| alias | command | description |
| ----- | ------- | ----------- |
| `ls` | `ls --group-directories-first --color=auto` | directories first, use color (applies to all ls aliases) |
| `l` | `ls -lAh` | all files, human-readable sizes |
| `lm` | `l | ${PAGER}` | all files, human-readable sizes, use pager |
| `ll` | `ls -lh` | human-readable sizes |
| `lr` | `ll -R` | human-readable sizes, recursive |
| `lx` | `ll -XB` | human-readable sizes, sort by extension (GNU only) |
| `lk` | `ll -Sr` | human-readable sizes, largest last |
| `lt` | `ll -tr` | human-readable sizes, most recent last |
| `lc` | `lt -c` | human-readable sizes, most recent last, change time |

### File Downloads

Aliases `get` to ( `aria2c` || `axel` || `wget` || `curl` ).

### Resource Usage

| alias | command |
| ----- | ------- |
| `df` | `df -kh` |
| `du` | `du -kh` |

### Condoms

| alias | command |
| ----- | ------- |
| `chmod` | `chmod --preserve-root -v` |
| `chown` | `chown --preserve-root -v` |
| `rm` | if available, `safe-rm` |

### Misc

| alias | description |
| ----- | ----------- |
| `mkcd` | `mkdir -p` and `cd` |
