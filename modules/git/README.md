Git
===

Provides nice git aliases and functions.

Many thanks to [Sorin Ionescu](https://github.com/sorin-ionescu) for the
excellent aliases.

Aliases
-------

### Git

  - `g` is short for `git`.

### Branch

  - `gb` lists, creates, renames, and deletes branches.
  - `gbc` creates a new branch.
  - `gbl` lists branches and their commits.
  - `gbL` lists local and remote branches and their commits.
  - `gbm` renames a branch.
  - `gbM` renames a branch even if the new branch name already exists.
  - `gbs` lists branches and their commits with ancestry graphs.
  - `gbS` lists local and remote branches and their commits with ancestry
    graphs.
  - `gbx` deletes a branch.
  - `gbX` deletes a branch irrespective of its merged status.

### Commit

  - `gc` records changes to the repository.
  - `gca` commits all modified and deleted files.
  - `gcm` commits with the given message.
  - `gco` checks out a branch or paths to the working tree.
  - `gcO` checks out hunks from the index or the tree interactively.
  - `gcf` amends the tip of the current branch reusing the same log message as
    *HEAD*.
  - `gcF` amends the tip of the current branch.
  - `gcp` applies changes introduced by existing commits.
  - `gcP` applies changes introduced by existing commits without committing.
  - `gcr` reverts existing commits by reverting patches and recording new
     commits.
  - `gcR` removes the *HEAD* commit.
  - `gcs` shows one or more objects (blobs, trees, tags and commits).
  - `gcS` commits with GPG signature.
  - `gcv` verifies the GPG signature of commits.

### Conflict

  - `gCl` lists unmerged files.
  - `gCa` adds unmerged file contents to the index.
  - `gCe` executes merge-tool on all unmerged files.
  - `gCo` checks out our changes for unmerged paths.
  - `gCO` checks out our changes for all unmerged paths.
  - `gCt` checks out their changes for unmerged paths.
  - `gCT` checks out their changes for all unmerged paths.

### Data

  - `gd` displays information about files in the index and the work tree.
  - `gdc` lists cached files.
  - `gdx` lists deleted files.
  - `gdm` lists modified files.
  - `gdu` lists untracked files.
  - `gdk` lists killed files.
  - `gdi` lists ignored files.

### Fetch

  - `gf` downloads objects and references from another repository.
  - `gfc` clones a repository into a new directory.
  - `gfm` fetches from and merges with another repository or local branch.
  - `gfr` fetches from and rebases on another repository or local branch.

### Grep

  - `gg` displays lines matching a pattern.
  - `ggi` displays lines matching a pattern ignoring case.
  - `ggl` lists files matching a pattern.
  - `ggL` lists files that are not matching a pattern.
  - `ggv` displays lines not matching a pattern.
  - `ggw` displays lines matching a pattern at word boundary.

### Index

  - `gia` adds file contents to the index.
  - `giA` adds file contents to the index interactively.
  - `giu` adds file contents to the index (updates only known files).
  - `gid` displays changes between the index and a named commit (diff).
  - `giD` displays changes between the index and a named commit (word diff).
  - `gir` resets the current *HEAD* to the specified state.
  - `giR` resets the current index interactively.
  - `gix` removes files/directories from the index (recursively).
  - `giX` removes files/directories from the index (recursively and forced).

### Log

  - `gl` displays the log.
  - `gls` displays the stats log.
  - `gld` displays the diff log.
  - `glo` displays the one line log.
  - `glO` displays the one line log with authors and dates.
  - `glg` displays the graph log.
  - `glG` displays the graph log with authors and dates.
  - `glv` displays the log verifying the GPG signature of commits.
  - `glc` displays the commit count for each contributor in descending order.

### Merge

  - `gm` joins two or more development histories together.
  - `gmC` performs the merge but does not commit.
  - `gmF` performs the merge generating a commit even if the merge resolved as a
    fast-forward.
  - `gma` aborts the conflict resolution, and reconstructs the pre-merge state.
  - `gmt` runs the merge conflict resolution tools to resolve conflicts.

### Push

  - `gp` updates remote refs along with associated objects.
  - `gpf` forces a push.
  - `gpa` pushes all branches.
  - `gpA` pushes all branches and tags.
  - `gpt` pushes all tags.
  - `gpc` pushes the current branch and adds *origin* as an upstream reference
    for it.
  - `gpp` pulls and pushes the current branch from *origin* to *origin*.

### Rebase

  - `gr` forward-ports local commits to the updated upstream head.
  - `gra` aborts the rebase.
  - `grc` continues the rebase after merge conflicts are resolved.
  - `gri` makes a list of commits to be rebased and opens the editor.
  - `grs` skips the current patch.

### Remote

  - `gR` manages tracked repositories.
  - `gRl` lists remote names and their URLs.
  - `gRa` adds a new remote.
  - `gRx` removes a remote.
  - `gRm` renames a remote.
  - `gRu` fetches remotes updates.
  - `gRp` prunes all stale remote tracking branches.
  - `gRs` shows information about a given remote.

### Stash

  - `gs` stashes the changes of the dirty working directory.
  - `gsa` applies the changes recorded in a stash to the working directory.
  - `gsx` drops a stashed state.
  - `gsX` drops all the stashed states.
  - `gsl` lists stashed states.
  - `gsd` displays changes between the stash and its original parent.
  - `gsp` removes and applies a single stashed state from the stash list.
  - `gsr` recovers a given stashed state.
  - `gss` stashes the working directory changes, including untracked files.
  - `gsS` stashes the working directory changes interactively.
  - `gsw` stashes the working directory changes retaining the index.
  - `gsu` unapplies (reverts) applied changes.

### Submodule

  - `gS` initializes, updates, or inspects submodules.
  - `gSa` adds given a repository as a submodule.
  - `gSf` evaluates a shell command in each of checked out submodules.
  - `gSi` initializes submodules.
  - `gSI` initializes and clones submodules recursively.
  - `gSl` lists the commits of all submodules.
  - `gSm` moves a submodule.
  - `gSs` synchronizes submodules' remote URL to the value specified in
    .gitmodules.
  - `gSu` fetches and merges the latest changes for all submodules.
  - `gSx` removes a submodule.

### Tag

  - `gt` creates, lists, deletes or verifies a tag object signed with GPG.
  - `gts` creates a GPG-signed tag.
  - `gtv` verifies the GPG signature of tags.
  - `gtx` deletes tags with given names.

### Working tree

  - `gws` displays working-tree status in the short format.
  - `gwS` displays working-tree status.
  - `gwd` displays changes between the working tree and the index (diff).
  - `gwD` displays changes between the working tree and the index (word diff).
  - `gwr` resets the current *HEAD* to the specified state, does not touch the
    index nor the working tree.
  - `gwR` resets the current *HEAD*, index and working tree to the specified
    state.
  - `gwc` cleans untracked files from the working tree (dry-run).
  - `gwC` cleans untracked files from the working tree.
  - `gwx` removes files from the working tree and from the index recursively.
  - `gwX` removes files from the working tree and from the index recursively and
    forcefully.

### Misc

  - `g..` changes the current directory to the top level of the working tree.

### Shadows

The following aliases may shadow system commands:

  - `gpt` shadows the GUID partition table maintenance utility.
  - `gs` shadows Ghostscript.

If you frequently use the above commands, you may wish to remove said aliases
from this module or to disable them at the bottom of the zshrc with `unalias`.

You can temporarily bypass an alias by prefixing it with a backward slash:
`\gpt`.

Functions
---------

  - `git-branch-current` displays the current branch.
  - `git-dir` displays the path to the Git directory.
  - `git-ignore-add` adds any arguments to the .gitignore in the project root.
  - `git-root` displays the path to the working tree root.
  - `git-stash-clear-interactive` asks for confirmation before clearing the stash.
  - `git-stash-recover` recovers given dropped stashed states.
  - `git-submodule-move` moves a submodule.
  - `git-submodule-remove` removes a submodule.
