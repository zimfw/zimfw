For bug reports, please provide the following information:

- [ ] I've checked the [existing issues](https://github.com/zimfw/zimfw/issues?q=is%3Aissue) to make sure I'm not duplicating a report.
- [ ] I've pasted the output of `zimfw info` below.
- [ ] I'm using the [latest version](https://github.com/zimfw/zimfw/releases/latest) of `zimfw`.
- [ ] I was able to reproduce the issue with a clean installation of Zim.

zimfw info
----------
<pre>
# In a terminal, run <b>zimfw info</b>, and paste the output here.
</pre>

Description
-----------


Steps to reproduce
------------------
(The fist 4 steps restart the shell with a clean installation of Zim in a temporary directory.)
1. `cd ${$(mktemp -d):A}`
2. `ZDOTDIR=${PWD} HOME=${PWD} ZIM_HOME=${PWD}/.zim exec zsh`
3. `curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh`
5. `exec zsh`
6. Other steps to reproduce. Use `exec zsh` when restarting the terminal or restarting the shell is needed.

Images or other information
---------------------------

