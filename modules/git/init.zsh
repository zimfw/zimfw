#
# Git aliases.
#

#
# Settings
#

# Log colour scheme has bold yellow commit hash, bold blue author, cyan date, auto ref names
# See https://git-scm.com/docs/pretty-formats
_git_log_medium_format='%C(bold)Commit: %C(yellow)%H%C(auto)%d%n%C(bold)Author: %C(blue)%an <%ae>%n%C(bold)Date:   %C(no-bold cyan)%ai (%ar)%C(reset)%n%+B'
_git_log_oneline_format='%C(bold yellow)%h%C(reset) %s%C(auto)%d%C(reset)'
_git_log_oneline_medium_format='%C(bold yellow)%h%C(reset) %<|(60,trunc)%s %C(bold blue)<%an> %C(no-bold cyan)(%ar)%C(auto)%d%C(reset)'

#
# Aliases
#

local gprefix
zstyle -s ':zim:git' aliases-prefix 'gprefix' || gprefix=g

# Git
alias ${gprefix}='git'

# Branch (b)
alias ${gprefix}b='git branch'
alias ${gprefix}bc='git checkout -b'
alias ${gprefix}bl='git branch -vv'
alias ${gprefix}bL='git branch --all -vv'
alias ${gprefix}bm='git branch --move'
alias ${gprefix}bM='git branch --move --force'
alias ${gprefix}bs='git show-branch'
alias ${gprefix}bS='git show-branch --all'
alias ${gprefix}bx='git-branch-delete-interactive'
alias ${gprefix}bX='git-branch-delete-interactive --force'

# Commit (c)
alias ${gprefix}c='git commit --verbose'
alias ${gprefix}ca='git commit --verbose --all'
alias ${gprefix}cm='git commit --message'
alias ${gprefix}co='git checkout'
alias ${gprefix}cO='git checkout --patch'
alias ${gprefix}cf='git commit --amend --reuse-message HEAD'
alias ${gprefix}cF='git commit --verbose --amend'
alias ${gprefix}cp='git cherry-pick --ff'
alias ${gprefix}cP='git cherry-pick --no-commit'
alias ${gprefix}cr='git revert'
alias ${gprefix}cR='git reset "HEAD^"'
alias ${gprefix}cs='git show --pretty=format:"${_git_log_medium_format}"'
alias ${gprefix}cS='git commit -S'
alias ${gprefix}cv='git verify-commit'

# Conflict (C)
alias ${gprefix}Cl='git --no-pager diff --diff-filter=U --name-only'
alias ${gprefix}Ca='git add $(gCl)'
alias ${gprefix}Ce='git mergetool $(gCl)'
alias ${gprefix}Co='git checkout --ours --'
alias ${gprefix}CO='gCo $(gCl)'
alias ${gprefix}Ct='git checkout --theirs --'
alias ${gprefix}CT='gCt $(gCl)'

# Data (d)
alias ${gprefix}d='git ls-files'
alias ${gprefix}dc='git ls-files --cached'
alias ${gprefix}dx='git ls-files --deleted'
alias ${gprefix}dm='git ls-files --modified'
alias ${gprefix}du='git ls-files --other --exclude-standard'
alias ${gprefix}dk='git ls-files --killed'
alias ${gprefix}di='git status --porcelain --short --ignored | sed -n "s/^!! //p"'

# Fetch (f)
alias ${gprefix}f='git fetch'
alias ${gprefix}fc='git clone'
alias ${gprefix}fm='git pull'
alias ${gprefix}fr='git pull --rebase'
alias ${gprefix}fu='git fetch --all --prune && git merge --ff-only @\{u\}'

# Grep (g)
alias ${gprefix}g='git grep'
alias ${gprefix}gi='git grep --ignore-case'
alias ${gprefix}gl='git grep --files-with-matches'
alias ${gprefix}gL='git grep --files-without-match'
alias ${gprefix}gv='git grep --invert-match'
alias ${gprefix}gw='git grep --word-regexp'

# Index (i)
alias ${gprefix}ia='git add'
alias ${gprefix}iA='git add --patch'
alias ${gprefix}iu='git add --update'
alias ${gprefix}id='git diff --no-ext-diff --cached'
alias ${gprefix}iD='git diff --no-ext-diff --cached --word-diff'
alias ${gprefix}ir='git reset'
alias ${gprefix}iR='git reset --patch'
alias ${gprefix}ix='git rm --cached -r'
alias ${gprefix}iX='git rm --cached -rf'

# Log (l)
alias ${gprefix}l='git log --topo-order --pretty=format:"${_git_log_medium_format}"'
alias ${gprefix}ls='git log --topo-order --stat --pretty=format:"${_git_log_medium_format}"'
alias ${gprefix}ld='git log --topo-order --stat --patch --full-diff --pretty=format:"${_git_log_medium_format}"'
alias ${gprefix}lo='git log --topo-order --pretty=format:"${_git_log_oneline_format}"'
alias ${gprefix}lO='git log --topo-order --pretty=format:"${_git_log_oneline_medium_format}"'
alias ${gprefix}lg='git log --topo-order --all --graph --pretty=format:"${_git_log_oneline_format}"'
alias ${gprefix}lG='git log --topo-order --all --graph --pretty=format:"${_git_log_oneline_medium_format}"'
alias ${gprefix}lv='git log --topo-order --show-signature --pretty=format:"${_git_log_medium_format}"'
alias ${gprefix}lc='git shortlog --summary --numbered'
alias ${gprefix}lr='git reflog'

# Merge (m)
alias ${gprefix}m='git merge'
alias ${gprefix}ma='git merge --abort'
alias ${gprefix}mC='git merge --no-commit'
alias ${gprefix}mF='git merge --no-ff'
alias ${gprefix}mS='git merge -S'
alias ${gprefix}mv='git merge --verify-signatures'
alias ${gprefix}mt='git mergetool'

# Push (p)
alias ${gprefix}p='git push'
alias ${gprefix}pf='git push --force-with-lease'
alias ${gprefix}pF='git push --force'
alias ${gprefix}pa='git push --all'
alias ${gprefix}pA='git push --all && git push --tags'
alias ${gprefix}pt='git push --tags'
alias ${gprefix}pc='git push --set-upstream origin "$(git-branch-current 2> /dev/null)"'
alias ${gprefix}pp='git pull origin "$(git-branch-current 2> /dev/null)" && git push origin "$(git-branch-current 2> /dev/null)"'

# Rebase (r)
alias ${gprefix}r='git rebase'
alias ${gprefix}ra='git rebase --abort'
alias ${gprefix}rc='git rebase --continue'
alias ${gprefix}ri='git rebase --interactive'
alias ${gprefix}rs='git rebase --skip'

# Remote (R)
alias ${gprefix}R='git remote'
alias ${gprefix}Rl='git remote --verbose'
alias ${gprefix}Ra='git remote add'
alias ${gprefix}Rx='git remote rm'
alias ${gprefix}Rm='git remote rename'
alias ${gprefix}Ru='git remote update'
alias ${gprefix}Rp='git remote prune'
alias ${gprefix}Rs='git remote show'

# Stash (s)
alias ${gprefix}s='git stash'
alias ${gprefix}sa='git stash apply'
alias ${gprefix}sx='git stash drop'
alias ${gprefix}sX='git-stash-clear-interactive'
alias ${gprefix}sl='git stash list'
alias ${gprefix}sd='git stash show --patch --stat'
alias ${gprefix}sp='git stash pop'
alias ${gprefix}sr='git-stash-recover'
alias ${gprefix}ss='git stash save --include-untracked'
alias ${gprefix}sS='git stash save --patch --no-keep-index'
alias ${gprefix}sw='git stash save --include-untracked --keep-index'
alias ${gprefix}su='git stash show --patch | git apply --reverse'

# Submodule (S)
alias ${gprefix}S='git submodule'
alias ${gprefix}Sa='git submodule add'
alias ${gprefix}Sf='git submodule foreach'
alias ${gprefix}Si='git submodule init'
alias ${gprefix}SI='git submodule update --init --recursive'
alias ${gprefix}Sl='git submodule status'
alias ${gprefix}Sm='git-submodule-move'
alias ${gprefix}Ss='git submodule sync'
alias ${gprefix}Su='git submodule foreach git pull origin master'
alias ${gprefix}Sx='git-submodule-remove'

# Tag (t)
alias ${gprefix}t='git tag'
alias ${gprefix}ts='git tag --sign'
alias ${gprefix}tv='git verify-tag'
alias ${gprefix}tx='git tag --delete'

# Working tree (w)
alias ${gprefix}ws='git status --short'
alias ${gprefix}wS='git status'
alias ${gprefix}wd='git diff --no-ext-diff'
alias ${gprefix}wD='git diff --no-ext-diff --word-diff'
alias ${gprefix}wr='git reset --soft'
alias ${gprefix}wR='git reset --hard'
alias ${gprefix}wc='git clean --dry-run'
alias ${gprefix}wC='git clean -d --force'
alias ${gprefix}wx='git rm -r'
alias ${gprefix}wX='git rm -rf'

# Misc
alias ${gprefix}..='cd "$(git-root || print .)"'
