Git-info
========

Exposes git repository status information to prompts.

Many thanks to [Sorin Ionescu](https://github.com/sorin-ionescu) and
[Colin Hebert](https://github.com/ColinHebert) for the original code.

Git **1.7.2** is the
[minimum required version](https://github.com/sorin-ionescu/prezto/issues/219).

Settings
--------

### Ignore Submodules

Retrieving the status of a repository with submodules can take a long time.
Submodules may be ignored when 'none', 'untracked', 'dirty', or 'all', which is
the default.

    zstyle ':zim:git-info' ignore-submodules 'none'

### Verbose Mode

Verbose mode uses `git status` and computes the count of indexed, unindexed and
also untracked files. It can be enabled with the following zstyle:

    zstyle ':zim:git-info' verbose 'yes'

In non-verbose mode, the 'untracked' context is not available (see Main
Contexts below), and untracked files are also not considered for computing the
'dirty' context. Using `git status` or checking for untracked files can be
[expensive](https://gist.github.com/sindresorhus/3898739).

Theming
-------

To display information about the current repository in a prompt, define your
custom styles in the `prompt_name_setup` function, where the syntax for setting
a style is:

    zstyle ':zim:git-info:context' format 'string'

### Main Contexts

| Name      |  Code  | Description
| --------- | :----: | --------------------------------------------------------
| action    |   %s   | Special action name (see Special Action Contexts below)
| ahead     |   %A   | Commits ahead of remote count
| behind    |   %B   | Commits behind of remote count
| diverged  |   %V   | Diverged commits (both ahead and behind are yield when it's not defined)
| branch    |   %b   | Branch name
| commit    |   %c   | Commit short hash (when in 'detached HEAD' state)
| clean     |   %C   | Clean state
| dirty     |   %D   | Dirty state (count with untracked files when verbose mode enabled)
| indexed   |   %i   | Indexed files (count when verbose mode enabled)
| unindexed |   %I   | Unindexed files (count when verbose mode enabled)
| position  |   %p   | Commits from nearest tag count (when in 'detached HEAD' state)
| remote    |   %R   | Remote name
| stashed   |   %S   | Stashed states count
| untracked |   %u   | Untracked files count (only when verbose mode enabled)

While `commit` and `position` are only available when in ['detached HEAD'
state](http://gitfaq.org/articles/what-is-a-detached-head.html), on the other
hand, `ahead`, `behind`, `diverged`, `branch` and `remote` are only available
when an actual branch is checked out (so when **not** in 'detached HEAD' state).

### Special Action Contexts

| Name                        | Format  | Default Value
| --------------------------- | :-----: | -------------------------------------
| action:apply                |  value  | 'apply'
| action:bisect               |  value  | 'bisect'
| action:cherry-pick          |  value  | 'cherry-pick'
| action:cherry-pick-sequence |  value  | 'cherry-pick-sequence'
| action:merge                |  value  | 'merge'
| action:rebase               |  value  | 'rebase'
| action:rebase-interactive   |  value  | 'rebase-interactive'
| action:rebase-merge         |  value  | 'rebase-merge'

Formatting example for special actions:

    zstyle ':zim:git-info:action:bisect' format '<B>'
    zstyle ':zim:git-info:action:merge'  format '>M<'
    zstyle ':zim:git-info:action:rebase' format '>R>'

### Usage

First, format the repository state attributes. For example, to format the
branch name, commit, and remote name, define the following styles:

    zstyle ':zim:git-info:branch' format 'branch:%b'
    zstyle ':zim:git-info:commit' format 'commit:%c'
    zstyle ':zim:git-info:remote' format 'remote:%R'

Second, format how the above attributes are displayed in prompts:

    zstyle ':zim:git-info:keys' format \
      'prompt'  'git(%b%c)' \
      'rprompt' '[%R]'

Last, add `$git_info[prompt]` to `$PROMPT` and `$git_info[rprompt]` to
`$RPROMPT` respectively and call `git-info` in the `prompt_name_precmd` hook
function.
