# .zlogin
#
# startup file read in interactive login shells
#
# The following code helps us by optimizing the existing framework.
# This includes zcompile, zcompdump, etc.
#

# # # old settings go here

(
  # Function to determine the need of a zcompile. If the .zwc file
  # does not exist, or the base file is newer, we need to compile.
  # These jobs are asynchronous, and will not impact the interactive shell
  zcompare() {
    if [[ -s ${1} && ( ! -s ${1}.zwc || ${1} -nt ${1}.zwc) ]]; then
      zcompile ${1};
    fi;
  }

  ZIM_MODS=${ZDOTDIR:-${HOME}}/.zim/modules
  setopt EXTENDED_GLOB

  # zcompile the completion cache; siginificant speedup.
  for file in ${ZDOTDIR:-${HOME}}/.zcomp^(*.zwc)(.); do
    zcompare ${file};
  done;

  # zcompile .zshrc
  zcompare ${ZDOTDIR:-${HOME}}/.zshrc

  # zcompile some light module init scripts
  zcompare ${ZIM_MODS}/git/init.zsh
  zcompare ${ZIM_MODS}/utility/init.zsh
  zcompare ${ZIM_MODS}/pacman/init.zsh
  zcompare ${ZIM_MODS}/spectrum/init.zsh
  zcompare ${ZIM_MODS}/completion/init.zsh
  zcompare ${ZIM_MODS}/fasd/init.zsh

  # zcompile all .zsh files in the custom module
  for file in ${ZIM_MODS}/custom/**/^(README.md|*.zwc)(.); do
    zcompare ${file};
  done;

  # zcompile all autoloaded functions
  for file in ${ZIM_MODS}/**/functions/^(*.zwc)(.); do
    zcompare ${file};
  done;

  # syntax-highlighting
  for file in ${ZIM_MODS}/syntax-highlighting/external/highlighters/**/*.zsh; do
    zcompare ${file};
  done;
  zcompare ${ZIM_MODS}/syntax-highlighting/external/zsh-syntax-highlighting.zsh

  # zsh-histery-substring-search
  zcompare ${ZIM_MODS}/history-substring-search/external/zsh-history-substring-search.zsh
) &!
