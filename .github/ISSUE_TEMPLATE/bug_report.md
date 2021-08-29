---
name: Bug report
about: Create a report to help us improve
title: ''
labels: bug
assignees: ''

---

- [ ] I've checked the [existing issues](https://github.com/zimfw/zimfw/issues?q=is%3Aissue) and I'm not duplicating a report.
- [ ] I'm using the [latest version](https://github.com/zimfw/zimfw/releases/latest) of `zimfw`.
- [ ] I've checked the [Changelog](https://github.com/zimfw/zimfw/blob/master/CHANGELOG.md) and I'm not being affected by documented changes.
- [ ] I've checked the [📢 Announcements](https://github.com/zimfw/zimfw/discussions/426) and I'm not being affected by announced changes.
- [ ] I was able to reproduce the issue with a clean installation of Zim.
- [ ] I've pasted the output of `zimfw info` below.

**Describe the bug**
A clear and concise description of what the bug is.

**Steps to reproduce**
The fist 4 steps restart the shell with a clean installation of Zim in a temporary directory.
Use `exec zsh` when restarting the terminal or restarting the shell is needed.
1. `cd ${$(mktemp -d):A}`
2. `ZDOTDIR=${PWD} HOME=${PWD} ZIM_HOME=${PWD}/.zim exec zsh`
3. `curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh`
4. `exec zsh`
5. Other steps to reproduce the behavior
6. The current unexpected behavior

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**zimfw info**
```
# In a terminal, run zimfw info, and paste the output here.
```

**Additional context**
Add any other context about the problem here.
