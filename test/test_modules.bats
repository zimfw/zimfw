setup() {
  # shellcheck disable=SC2034
  BATS_LIB_PATH="${BATS_TEST_DIRNAME}"/test_helper
  bats_load_library setup_all
  setup_all
}

@test 'can define module with custom cmd' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule test --use mkdir --on-pull '>init.zsh <<<"print test"' --cmd 'cat {}/init.zsh'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
cat "\${HOME}/.zim/modules/test"/init.zsh
EOF

  run zsh zimfw.zsh init
  assert_success
  assert_output ') modules/test: Created'
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh -ic 'exit'
  assert_success
  assert_output 'print test'
}

@test 'can define module with custom URL' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule https://gist.github.com/agnoster/3712874 -n agnoster
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/agnoster/agnoster.zsh-theme"
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_output ') modules/agnoster: Installed'
  assert_exists "${ZIM_HOME}"/modules/agnoster/.git
  assert_file_exists "${ZIM_HOME}"/modules/agnoster/agnoster.zsh-theme
  assert_file_exists "${ZIM_HOME}"/modules/agnoster/agnoster.zsh-theme.zwc
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh
}

@test 'can define module with multiple source files' {
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
  assert_output ') modules/pure: Installed'
  assert_exists "${ZIM_HOME}"/modules/pure/.git
  assert_file_exists "${ZIM_HOME}"/modules/pure/async.zsh
  assert_file_exists "${ZIM_HOME}"/modules/pure/async.zsh.zwc
  assert_file_exists "${ZIM_HOME}"/modules/pure/pure.zsh
  assert_file_exists "${ZIM_HOME}"/modules/pure/pure.zsh.zwc
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/pure
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
  assert_output "modules/pure
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
  assert_output "modules/pure
  From: https://github.com/sindresorhus/pure.git, default branch, using git
  if: [[ \${TERM_PROGRAM} == Apple_Terminal ]]
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
  assert_output "modules/pure (frozen)
  if: [[ \${TERM_PROGRAM} == Apple_Terminal ]]
  cmd: source \"\${HOME}/.zim/modules/pure/async.zsh\"; source \"\${HOME}/.zim/modules/pure/pure.zsh\""

  cat >"${HOME}"/.zimrc <<EOF
zmodule sindresorhus/pure --source async.zsh
zmodule sindresorhus/pure --if '[[ \${TERM_PROGRAM} == Apple_Terminal ]]' --disabled
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
  assert_output "modules/pure (disabled)
  From: https://github.com/sindresorhus/pure.git, default branch, using git
  if: [[ \${TERM_PROGRAM} == Apple_Terminal ]]"
}

@test 'can define modules with custom options' {
  mkdir "${HOME}"/external
  cat >"${HOME}"/external/init.zsh <<EOF
print external
EOF
  cat >"${HOME}"/.zimrc <<EOF
zmodule macports --name zimfw/macports --if-ostype 'darwin*'
zmodule duration-info -n zimfw/duration-info --frozen --disabled
zmodule git-info -n zimfw/git-info --if-command git
zmodule asciiship -n zimfw/asciiship  --if '[[ -z \${NO_COLOR} ]]' -c 'source {}/asciiship.zsh-theme'
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
  source "\${HOME}/.zim/modules/zimfw/asciiship"/asciiship.zsh-theme
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
  assert_equal "${#lines[@]}" 6
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
  assert_line ') modules/zimfw/duration-info: Skipping frozen module'
  assert_line ') modules/zimfw/macports: Already up to date'
  assert_line ') modules/zimfw/git-info: Already up to date'
  assert_line ') modules/zimfw/asciiship: Already up to date'
  assert_line ') modules/zsh-completions: Already up to date'
  assert_line ') modules/zsh-syntax-highlighting: Already up to date'
  assert_line ') modules/test: Skipping mkdir module'
  assert_line ') external: Skipping external module'
  assert_line --index 8 'Done with check. Run zimfw update to update modules.'
  assert_equal "${#lines[@]}" 9

  run zsh "${PWD}"/zimfw.zsh clean-compiled
  assert_success
  assert_line --index 14 'Done with clean-compiled. Restart your terminal or run zimfw compile to re-compile.'
  assert_equal "${#lines[@]}" 15

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
  assert_output "modules/zimfw/macports
modules/zimfw/duration-info (not installed) (frozen) (disabled)
modules/zimfw/git-info
modules/zimfw/asciiship
modules/zsh-completions
modules/zsh-syntax-highlighting
modules/test
external (external)"

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/zimfw/macports
  From: https://github.com/zimfw/macports.git, default branch, using git
  if: [[ \${OSTYPE} == darwin* ]]
  cmd: source \"\${HOME}/.zim/modules/zimfw/macports/init.zsh\"
modules/zimfw/duration-info (not installed) (frozen) (disabled)
modules/zimfw/git-info
  From: https://github.com/zimfw/git-info.git, default branch, using git
  if: (( \${+commands[git]} ))
  fpath: \"\${HOME}/.zim/modules/zimfw/git-info/functions\"
  autoload: coalesce git-action git-info
modules/zimfw/asciiship
  From: https://github.com/zimfw/asciiship.git, default branch, using git
  if: [[ -z \${NO_COLOR} ]]
  cmd: source \"\${HOME}/.zim/modules/zimfw/asciiship\"/asciiship.zsh-theme
modules/zsh-completions
  From: https://github.com/zsh-users/zsh-completions.git, default branch, using degit
  fpath: \"\${HOME}/.zim/modules/zsh-completions/src\"
modules/zsh-syntax-highlighting
  From: https://github.com/zsh-users/zsh-syntax-highlighting.git, default branch, using git
  if: [[ -z \${NO_COLOR} ]]
  cmd: source \"\${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"
modules/test
  From: mkdir
  On-pull: >init.zsh <<<\"print test\"
  cmd: source \"\${HOME}/.zim/modules/test/init.zsh\"
external (external)
  From: ${HOME}/external
  cmd: source \"\${HOME}/external/init.zsh\""

  cat >"${HOME}"/.zimrc <<EOF
zmodule git-info -n zimfw/git-info -d
zmodule asciiship -n zimfw/asciiship -u degit -z
zmodule zsh-users/zsh-completions -u git -f src
zmodule zsh-users/zsh-syntax-highlighting -u degit
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
  assert_output "modules/zimfw/git-info (disabled)
modules/zimfw/asciiship (frozen)
modules/zsh-completions
modules/zsh-syntax-highlighting
modules/test (unused)
modules/zimfw/macports (unused)"

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/zimfw/git-info (disabled)
  From: https://github.com/zimfw/git-info.git, default branch, using git
modules/zimfw/asciiship (frozen)
  cmd: source \"\${HOME}/.zim/modules/zimfw/asciiship/asciiship.zsh-theme\"
modules/zsh-completions
  From: https://github.com/zsh-users/zsh-completions.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/zsh-completions/src\"
modules/zsh-syntax-highlighting
  From: https://github.com/zsh-users/zsh-syntax-highlighting.git, default branch, using degit
  cmd: source \"\${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"
modules/test (unused)
modules/zimfw/macports (unused)"

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
  assert_equal "${#lines[@]}" 2

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
  assert_line --index 4 'Done with check. Run zimfw update to update modules.'
  assert_equal "${#lines[@]}" 5
}

@test 'can define external module with custom name' {
  mkdir "${HOME}"/external-zsh
  cat >"${HOME}"/external-zsh/external.zsh <<EOF
print external
EOF
  cat >"${HOME}"/.zimrc <<EOF
zmodule ${HOME}/external-zsh --name external
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/external-zsh/external.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_output ''
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh -ic exit
  assert_success
  assert_output 'external'

  run zsh "${PWD}"/zimfw.zsh check -v
  assert_success
  assert_output ") external: Skipping external module
Done with check. Run zimfw update to update modules."

  run zsh "${PWD}"/zimfw.zsh list
  assert_success
  assert_output "external (external)"

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "external (external)
  From: ${HOME}/external-zsh
  cmd: source \"\${HOME}/external-zsh/external.zsh\""
}
