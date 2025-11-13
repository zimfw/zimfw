setup() {
  # shellcheck disable=SC2034
  BATS_LIB_PATH="${BATS_TEST_DIRNAME}"/test_helper
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file

  assert_file_exists "${PWD}"/zimfw.zsh
  export HOME="${BATS_TEST_TMPDIR}"
  export ZIM_HOME="${HOME}"/.zim
  cat >"${HOME}"/.zshrc <<EOF
source ${ZIM_HOME}/init.zsh
EOF
}

@test 'can print info' {
  run zsh "${PWD}"/zimfw.zsh info
  assert_success
  assert_line "ZIM_HOME:             ${ZIM_HOME}"
  assert_line "zimfw config:         ${HOME}/.zimrc"
  assert_line "zimfw script:         ${PWD}/zimfw.zsh"
}

@test 'can turn script to absolute path' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule test --use mkdir --on-pull '>init.zsh <<<"print test"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/test/init.zsh"
EOF

  run zsh zimfw.zsh init
  assert_success
  assert_output ') modules/test: Created'
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh zimfw.zsh info
  assert_success
  assert_line "zimfw script:         ${PWD}/zimfw.zsh"

  run zsh -ic 'zimfw info'
  assert_success
  assert_line "zimfw script:         ${PWD}/zimfw.zsh"
}

@test 'can check-version' {
  run zsh "${PWD}"/zimfw.zsh check-version
  assert_success
  assert_output ''
  assert_file_exists "${ZIM_HOME}"/.latest_version
  LATEST_VERSION="$(<"${ZIM_HOME}"/.latest_version)"

  run zsh "${PWD}"/zimfw.zsh version
  assert_success
  assert_output "${LATEST_VERSION}"
}

@test 'can define modules' {
  command -v git # assert git command installed
  mkdir "${HOME}"/external
  cat >"${HOME}"/external/init.zsh <<EOF
print external
EOF
  cat >"${HOME}"/.zimrc <<EOF
zmodule macports --name zimfw/macports --if-ostype 'darwin*'
zmodule duration-info -n zimfw/duration-info --frozen --disabled
zmodule git-info -n zimfw/git-info --if-command git
zmodule asciiship -n zimfw/asciiship  --if '[[ -z \${NO_COLOR} ]]'
zmodule zsh-users/zsh-completions --use degit --fpath src
zmodule zsh-users/zsh-syntax-highlighting --if '[[ -z \${NO_COLOR} ]]'
zmodule test --use mkdir --on-pull '>init.zsh <<<"print test"'
zmodule ${HOME}/external
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
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

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_line ') modules/zimfw/macports: Installed'
  assert_line ') modules/zimfw/git-info: Installed'
  assert_line ') modules/zimfw/asciiship: Installed'
  assert_line ') modules/zsh-completions: Installed'
  assert_line ') modules/zsh-syntax-highlighting: Installed'
  assert_line ') modules/test: Created'
  assert_exists "${ZIM_HOME}"/modules/zimfw/macports/.git
  assert_file_exists "${ZIM_HOME}"/modules/zimfw/macports/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/zimfw/macports/init.zsh.zwc
  assert_dir_not_exists "${ZIM_HOME}"/modules/zimfw/duration-info
  assert_exists "${ZIM_HOME}"/modules/zimfw/git-info/.git
  assert_file_exists "${ZIM_HOME}"/modules/zimfw/git-info/functions/coalesce
  assert_file_exists "${ZIM_HOME}"/modules/zimfw/git-info/functions/git-action
  assert_file_exists "${ZIM_HOME}"/modules/zimfw/git-info/functions/git-info
  assert_exists "${ZIM_HOME}"/modules/zimfw/asciiship/.git
  assert_file_exists "${ZIM_HOME}"/modules/zimfw/asciiship/asciiship.zsh-theme
  assert_file_exists "${ZIM_HOME}"/modules/zimfw/asciiship/asciiship.zsh-theme.zwc
  assert_file_exists "${ZIM_HOME}"/modules/zsh-completions/.zdegit
  assert_dir_exists "${ZIM_HOME}"/modules/zsh-completions/src
  assert_exists "${ZIM_HOME}"/modules/zsh-syntax-highlighting/.git
  assert_file_exists "${ZIM_HOME}"/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  assert_file_exists "${ZIM_HOME}"/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh.zwc
  assert_not_exists "${ZIM_HOME}"/modules/test/.git
  assert_not_exists "${ZIM_HOME}"/modules/test/.zdegit
  assert_file_exists "${ZIM_HOME}"/modules/test/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/test/init.zsh.zwc
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh -ic exit
  assert_success
  assert_output 'test
external'

  run zsh "${PWD}"/zimfw.zsh check -v
  assert_success
  assert_line ') modules/zimfw/macports: Already up to date'
  assert_line ') modules/zimfw/git-info: Already up to date'
  assert_line ') modules/zimfw/asciiship: Already up to date'
  assert_line ') modules/zsh-completions: Already up to date'
  assert_line ') modules/zsh-syntax-highlighting: Already up to date'
  assert_line ') modules/test: Skipping mkdir module'
  assert_line ') external: Skipping external module'
  assert_line 'Done with check. Run zimfw update to update modules.'

  run zsh "${PWD}"/zimfw.zsh clean-compiled
  assert_success
  REAL_HOME="$(realpath "${HOME}")"
  REAL_ZIM_HOME="$(realpath "${ZIM_HOME}")"
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

  run zsh "${PWD}"/zimfw.zsh compile
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

  run zsh "${PWD}"/zimfw.zsh list
  assert_success
  assert_output "modules/zimfw/macports: ${ZIM_HOME}/modules/zimfw/macports
modules/zimfw/duration-info: ${ZIM_HOME}/modules/zimfw/duration-info (not installed) (frozen) (disabled)
modules/zimfw/git-info: ${ZIM_HOME}/modules/zimfw/git-info
modules/zimfw/asciiship: ${ZIM_HOME}/modules/zimfw/asciiship
modules/zsh-completions: ${ZIM_HOME}/modules/zsh-completions
modules/zsh-syntax-highlighting: ${ZIM_HOME}/modules/zsh-syntax-highlighting
modules/test: ${ZIM_HOME}/modules/test
external: ${HOME}/external (external)"

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/zimfw/macports: ${ZIM_HOME}/modules/zimfw/macports
  From: https://github.com/zimfw/macports.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/zimfw/macports/init.zsh\"
modules/zimfw/duration-info: ${ZIM_HOME}/modules/zimfw/duration-info (not installed) (frozen) (disabled)
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

  cat >"${HOME}"/.zimrc <<EOF
zmodule git-info -n zimfw/git-info --disabled
zmodule asciiship -n zimfw/asciiship --use degit --frozen
zmodule zsh-users/zsh-completions --use git --fpath src
zmodule zsh-users/zsh-syntax-highlighting --use degit
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
fpath=("\${HOME}/.zim/modules/zsh-completions/src" \${fpath})
source "\${HOME}/.zim/modules/zimfw/asciiship/asciiship.zsh-theme"
source "\${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh list
  assert_success
  assert_output "modules/zimfw/git-info: ${ZIM_HOME}/modules/zimfw/git-info (disabled)
modules/zimfw/asciiship: ${ZIM_HOME}/modules/zimfw/asciiship (frozen)
modules/zsh-completions: ${ZIM_HOME}/modules/zsh-completions
modules/zsh-syntax-highlighting: ${ZIM_HOME}/modules/zsh-syntax-highlighting
modules/test: ${ZIM_HOME}/modules/test (unused)
modules/zimfw/macports: ${ZIM_HOME}/modules/zimfw/macports (unused)"

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/zimfw/git-info: ${ZIM_HOME}/modules/zimfw/git-info (disabled)
  From: https://github.com/zimfw/git-info.git, default branch, using git
modules/zimfw/asciiship: ${ZIM_HOME}/modules/zimfw/asciiship (frozen)
  cmd: source \"\${HOME}/.zim/modules/zimfw/asciiship/asciiship.zsh-theme\"
modules/zsh-completions: ${ZIM_HOME}/modules/zsh-completions
  From: https://github.com/zsh-users/zsh-completions.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/zsh-completions/src\"
modules/zsh-syntax-highlighting: ${ZIM_HOME}/modules/zsh-syntax-highlighting
  From: https://github.com/zsh-users/zsh-syntax-highlighting.git, default branch, using degit
  cmd: source \"\${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"
modules/test: ${ZIM_HOME}/modules/test (unused)
modules/zimfw/macports: ${ZIM_HOME}/modules/zimfw/macports (unused)"

  run zsh "${PWD}"/zimfw.zsh uninstall -q
  assert_success
  assert_output ''
  assert_exists "${ZIM_HOME}"/modules/zimfw/git-info/.git
  assert_exists "${ZIM_HOME}"/modules/zimfw/asciiship/.git
  assert_file_exists "${ZIM_HOME}"/modules/zsh-completions/.zdegit
  assert_exists "${ZIM_HOME}"/modules/zsh-syntax-highlighting/.git
  assert_dir_not_exists "${ZIM_HOME}"/modules/test
  assert_dir_not_exists "${ZIM_HOME}"/modules/zimfw/macports
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh -ic exit
  assert_success
  assert_output ''

  run zsh "${PWD}"/zimfw.zsh check
  assert_success
  assert_line "x modules/zsh-completions: Module was not installed using git. Use zmodule option -z|--frozen to disable this error or run zimfw reinstall to reinstall."
  assert_line "x modules/zsh-syntax-highlighting: Module was not installed using zimfw's degit. Use zmodule option -z|--frozen to disable this error or run zimfw reinstall to reinstall."

  run zsh "${PWD}"/zimfw.zsh reinstall -q
  assert_success
  assert_output "x modules/zsh-completions: Module was not installed using git.
x modules/zsh-syntax-highlighting: Module was not installed using zimfw's degit."
  assert_exists "${ZIM_HOME}"/modules/zsh-completions/.git
  assert_file_exists "${ZIM_HOME}"/modules/zsh-syntax-highlighting/.zdegit
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh check -v
  assert_success
  assert_line ') modules/zimfw/git-info: Already up to date'
  assert_line ') modules/zimfw/asciiship: Skipping frozen module'
  assert_line ') modules/zsh-completions: Already up to date'
  assert_line ') modules/zsh-syntax-highlighting: Already up to date'
  assert_line 'Done with check. Run zimfw update to update modules.'
}

@test 'can define multiple source files from one module' {
  command -v git # assert git command installed
  cat >"${HOME}"/.zimrc <<EOF
zmodule sindresorhus/pure -s async.zsh -s pure.zsh
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/pure/async.zsh"
source "\${HOME}/.zim/modules/pure/pure.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_line ') modules/pure: Installed'
  assert_exists "${ZIM_HOME}"/modules/pure/.git
  assert_file_exists "${ZIM_HOME}"/modules/pure/async.zsh
  assert_file_exists "${ZIM_HOME}"/modules/pure/async.zsh.zwc
  assert_file_exists "${ZIM_HOME}"/modules/pure/pure.zsh
  assert_file_exists "${ZIM_HOME}"/modules/pure/pure.zsh.zwc
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/pure: ${ZIM_HOME}/modules/pure
  From: https://github.com/sindresorhus/pure.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/pure/async.zsh\"; source \"\${HOME}/.zim/modules/pure/pure.zsh\""

  cat >"${HOME}"/.zimrc <<EOF
zmodule sindresorhus/pure --source async.zsh
zmodule sindresorhus/pure
EOF

  run zsh "${PWD}"/zimfw.zsh build
  assert_success
  assert_output ") ${ZIM_HOME}/init.zsh: Updated
) ${ZIM_HOME}/login_init.zsh: Updated
Done with build. Restart your terminal for changes to take effect."
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/pure: ${ZIM_HOME}/modules/pure
  From: https://github.com/sindresorhus/pure.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/pure/async.zsh\"; source \"\${HOME}/.zim/modules/pure/pure.zsh\""

  cat >"${HOME}"/.zimrc <<EOF
zmodule sindresorhus/pure --source async.zsh
zmodule sindresorhus/pure --if '[[ \${TERM_PROGRAM} == Apple_Terminal ]]'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
if [[ \${TERM_PROGRAM} == Apple_Terminal ]]; then
  source "\${HOME}/.zim/modules/pure/async.zsh"
  source "\${HOME}/.zim/modules/pure/pure.zsh"
fi
EOF

  run zsh "${PWD}"/zimfw.zsh build
  assert_success
  assert_output ") ${ZIM_HOME}/init.zsh: Updated
) ${ZIM_HOME}/login_init.zsh: Updated
Done with build. Restart your terminal for changes to take effect."
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/pure: ${ZIM_HOME}/modules/pure
  From: https://github.com/sindresorhus/pure.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/pure/async.zsh\"; source \"\${HOME}/.zim/modules/pure/pure.zsh\""

  cat >"${HOME}"/.zimrc <<EOF
zmodule sindresorhus/pure --source async.zsh
zmodule sindresorhus/pure --frozen --if '[[ \${TERM_PROGRAM} == Apple_Terminal ]]'
EOF

  run zsh "${PWD}"/zimfw.zsh update -v
  assert_success
  assert_output ") modules/pure: Skipping frozen module
Done with update. Restart your terminal for changes to take effect.
) ${ZIM_HOME}/init.zsh: Updated
) ${ZIM_HOME}/login_init.zsh: Updated
Done with build. Restart your terminal for changes to take effect.
Done with compile."
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/pure: ${ZIM_HOME}/modules/pure (frozen)
  cmd: source \"\${HOME}/.zim/modules/pure/async.zsh\"; source \"\${HOME}/.zim/modules/pure/pure.zsh\""

  cat >"${HOME}"/.zimrc <<EOF
zmodule sindresorhus/pure --source async.zsh
zmodule sindresorhus/pure --disabled
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
EOF

  run zsh "${PWD}"/zimfw.zsh build
  assert_success
  assert_output ") ${ZIM_HOME}/init.zsh: Updated
) ${ZIM_HOME}/login_init.zsh: Updated
Done with build. Restart your terminal for changes to take effect."
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/pure: ${ZIM_HOME}/modules/pure (disabled)
  From: https://github.com/sindresorhus/pure.git, default branch, using git"
}
