setup() {
  BATS_LIB_PATH=${BATS_TEST_DIRNAME}/test_helper
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file
}

@test 'can print info' {
  export HOME=${BATS_TEST_TMPDIR}
  export ZIM_HOME=${HOME}/.zim

  run zsh ${PWD}/zimfw.zsh info
  assert_success
  assert_line "ZIM_HOME:             ${ZIM_HOME}"
  assert_line "zimfw config:         ${HOME}/.zimrc"
  assert_line "zimfw script:         ${PWD}/zimfw.zsh"
}

@test 'can check-version' {
  export HOME=${BATS_TEST_TMPDIR}
  export ZIM_HOME=${HOME}/.zim

  run zsh ${PWD}/zimfw.zsh check-version
  assert_success
  assert_output ''
  assert_file_exists ${ZIM_HOME}/.latest_version
  LATEST_VERSION=$(<${ZIM_HOME}/.latest_version)

  run zsh ${PWD}/zimfw.zsh version
  assert_success
  assert_output ${LATEST_VERSION}
}

@test 'can define modules' {
  command -v git # assert git command installed
  export HOME=${BATS_TEST_TMPDIR}
  export ZIM_HOME=${HOME}/.zim
  mkdir ${HOME}/external
  cat >${HOME}/external/init.zsh <<EOF
print external
EOF
  cat >${HOME}/.zimrc <<EOF
zmodule macports -n zimfw/macports --if-ostype 'darwin*'
zmodule git-info -n zimfw/git-info --if-command git
zmodule asciiship -n zimfw/asciiship  --if '[[ -z \${NO_COLOR} ]]'
zmodule zsh-users/zsh-completions --use degit --fpath src
zmodule zsh-users/zsh-syntax-highlighting --if '[[ -z \${NO_COLOR} ]]'
zmodule test --use mkdir --on-pull '>init.zsh <<<"print test"'
zmodule ${HOME}/external
EOF
  cat >${HOME}/expected.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
fpath=("\${HOME}/.zim/modules/zimfw/git-info/functions" "\${HOME}/.zim/modules/zsh-completions/src" \${fpath})
if [[ \${OSTYPE} == darwin* ]]; then
  source "\${HOME}/.zim/modules/zimfw/macports/init.zsh"
fi
if (( \${+commands[git]} )); then
  autoload -Uz -- coalesce git-action git-info
fi
if [[ -z \${NO_COLOR} ]]; then
  source "\${HOME}/.zim/modules/zimfw/asciiship/asciiship.zsh-theme"
fi
if [[ -z \${NO_COLOR} ]]; then
  source "\${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
source "\${HOME}/.zim/modules/test/init.zsh"
source "\${HOME}/external/init.zsh"
EOF

  run zsh ${PWD}/zimfw.zsh init
  assert_success
  assert_line ') modules/zimfw/macports: Installed'
  assert_line ') modules/zimfw/git-info: Installed'
  assert_line ') modules/zimfw/asciiship: Installed'
  assert_line ') modules/zsh-completions: Installed'
  assert_line ') modules/zsh-syntax-highlighting: Installed'
  assert_line ') modules/test: Created'
  assert_exists ${ZIM_HOME}/modules/zimfw/macports/.git
  assert_file_exists ${ZIM_HOME}/modules/zimfw/macports/init.zsh
  assert_file_exists ${ZIM_HOME}/modules/zimfw/macports/init.zsh.zwc
  assert_exists ${ZIM_HOME}/modules/zimfw/git-info/.git
  assert_file_exists ${ZIM_HOME}/modules/zimfw/git-info/functions/coalesce
  assert_file_exists ${ZIM_HOME}/modules/zimfw/git-info/functions/git-action
  assert_file_exists ${ZIM_HOME}/modules/zimfw/git-info/functions/git-info
  assert_exists ${ZIM_HOME}/modules/zimfw/asciiship/.git
  assert_file_exists ${ZIM_HOME}/modules/zimfw/asciiship/asciiship.zsh-theme
  assert_file_exists ${ZIM_HOME}/modules/zimfw/asciiship/asciiship.zsh-theme.zwc
  assert_file_exists ${ZIM_HOME}/modules/zsh-completions/.zdegit
  assert_dir_exists ${ZIM_HOME}/modules/zsh-completions/src
  assert_exists ${ZIM_HOME}/modules/zsh-syntax-highlighting/.git
  assert_file_exists ${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  assert_file_exists ${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh.zwc
  assert_not_exists ${ZIM_HOME}/modules/test/.git
  assert_not_exists ${ZIM_HOME}/modules/test/.zdegit
  assert_file_exists ${ZIM_HOME}/modules/test/init.zsh
  assert_file_exists ${ZIM_HOME}/modules/test/init.zsh.zwc
  assert_files_equal ${ZIM_HOME}/init.zsh ${HOME}/expected.zsh
  cat >${HOME}/.zshrc <<EOF
source ${ZIM_HOME}/init.zsh
EOF

  run zsh -ic exit
  assert_success
  assert_output 'test
external'

  run zsh ${PWD}/zimfw.zsh check -v
  assert_success
  assert_line ') modules/zimfw/macports: Already up to date'
  assert_line ') modules/zimfw/git-info: Already up to date'
  assert_line ') modules/zimfw/asciiship: Already up to date'
  assert_line ') modules/zsh-completions: Already up to date'
  assert_line ') modules/zsh-syntax-highlighting: Already up to date'
  assert_line ') external: Skipping external module'
  assert_line 'Done with check. Run zimfw update to update modules.'

  run zsh ${PWD}/zimfw.zsh clean-compiled
  assert_success
  REAL_HOME=$(realpath ${HOME})
  REAL_ZIM_HOME=$(realpath ${ZIM_HOME})
  assert_output "${REAL_ZIM_HOME}/modules/test/init.zsh.zwc
${REAL_ZIM_HOME}/modules/zimfw/asciiship/asciiship.zsh-theme.zwc
${REAL_ZIM_HOME}/modules/zimfw/macports/init.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-completions/zsh-completions.plugin.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/brackets/brackets-highlighter.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/cursor/cursor-highlighter.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/line/line-highlighter.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/pattern/pattern-highlighter.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/regexp/regexp-highlighter.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/root/root-highlighter.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh.zwc
${REAL_ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh.zwc
${REAL_HOME}/external/init.zsh.zwc
Done with clean-compiled. Restart your terminal or run zimfw compile to re-compile."

  run zsh ${PWD}/zimfw.zsh compile
  assert_success
  assert_output ") ${ZIM_HOME}/modules/zimfw/macports/init.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zimfw/asciiship/asciiship.zsh-theme.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-completions/zsh-completions.plugin.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/brackets/brackets-highlighter.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/cursor/cursor-highlighter.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/line/line-highlighter.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/main/main-highlighter.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/pattern/pattern-highlighter.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/regexp/regexp-highlighter.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/highlighters/root/root-highlighter.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh.zwc: Compiled
) ${ZIM_HOME}/modules/test/init.zsh.zwc: Compiled
) ${HOME}/external/init.zsh.zwc: Compiled
Done with compile."

  run zsh ${PWD}/zimfw.zsh list
  assert_success
  assert_output "modules/zimfw/macports: ${ZIM_HOME}/modules/zimfw/macports
modules/zimfw/git-info: ${ZIM_HOME}/modules/zimfw/git-info
modules/zimfw/asciiship: ${ZIM_HOME}/modules/zimfw/asciiship
modules/zsh-completions: ${ZIM_HOME}/modules/zsh-completions
modules/zsh-syntax-highlighting: ${ZIM_HOME}/modules/zsh-syntax-highlighting
modules/test: ${ZIM_HOME}/modules/test
external: ${HOME}/external (external)"

  run zsh ${PWD}/zimfw.zsh list -v
  assert_success
  assert_output "modules/zimfw/macports: ${ZIM_HOME}/modules/zimfw/macports
  From: https://github.com/zimfw/macports.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/zimfw/macports/init.zsh\"
modules/zimfw/git-info: ${ZIM_HOME}/modules/zimfw/git-info
  From: https://github.com/zimfw/git-info.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/zimfw/git-info/functions\"
  autoload: coalesce git-action git-info
modules/zimfw/asciiship: ${ZIM_HOME}/modules/zimfw/asciiship
  From: https://github.com/zimfw/asciiship.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/zimfw/asciiship/asciiship.zsh-theme\"
modules/zsh-completions: ${ZIM_HOME}/modules/zsh-completions
  From: https://github.com/zsh-users/zsh-completions.git, default branch, using degit
  fpath: \"\${HOME}/.zim/modules/zsh-completions/src\"
modules/zsh-syntax-highlighting: ${ZIM_HOME}/modules/zsh-syntax-highlighting
  From: https://github.com/zsh-users/zsh-syntax-highlighting.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"
modules/test: ${ZIM_HOME}/modules/test
  From: mkdir
  On-pull: >init.zsh <<<\"print test\"
  cmd: source \"\${HOME}/.zim/modules/test/init.zsh\"
external: ${HOME}/external (external)
  cmd: source \"\${HOME}/external/init.zsh\""
}
