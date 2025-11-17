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

@test 'can define module with roots' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule custom --use mkdir --on-pull '>init.zsh <<<"print custom"'
zmodule custom --root 1 --on-pull '>init.zsh <<<"print custom1"'
zmodule custom --root 2 --on-pull '>init.zsh <<<"print custom2"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/custom/init.zsh"
source "\${HOME}/.zim/modules/custom/1/init.zsh"
source "\${HOME}/.zim/modules/custom/2/init.zsh"
EOF

  run zsh zimfw.zsh init
  assert_success
  assert_output ') modules/custom: Created'
  assert_file_exists "${ZIM_HOME}"/modules/custom/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/1/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/2/init.zsh
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh zimfw.zsh list -v
  assert_success
  assert_output "modules/custom: ${ZIM_HOME}/modules/custom
  From: mkdir
  On-pull: >init.zsh <<<\"print custom\"; (builtin cd -q 1; >init.zsh <<<\"print custom1\"); (builtin cd -q 2; >init.zsh <<<\"print custom2\")
  Root: ${ZIM_HOME}/modules/custom
    cmd: source \"\${HOME}/.zim/modules/custom/init.zsh\"
  Root: ${ZIM_HOME}/modules/custom/1
    cmd: source \"\${HOME}/.zim/modules/custom/1/init.zsh\"
  Root: ${ZIM_HOME}/modules/custom/2
    cmd: source \"\${HOME}/.zim/modules/custom/2/init.zsh\""
}

@test 'can define module with roots and custom options' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule custom --root 1 --use mkdir --on-pull '>init.zsh <<<"print \\\${CUSTOM1}"' --if '[[ -n \${CUSTOM1} ]]'
zmodule custom --root 2 --on-pull '>init.zsh <<<"print custom2"'
zmodule custom --root 3 --on-pull '>init.zsh <<<"print custom3"' --if-command cat --cmd 'cat {}/init.zsh'
zmodule custom --root 1 -c 'print -R "\${(F)\$(<{}/init.zsh)}"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
if [[ -n \${CUSTOM1} ]]; then
  source "\${HOME}/.zim/modules/custom/1/init.zsh"
  print -R "\${(F)\$(<"\${HOME}/.zim/modules/custom/1"/init.zsh)}"
fi
source "\${HOME}/.zim/modules/custom/2/init.zsh"
if (( \${+commands[cat]} )); then
  cat "\${HOME}/.zim/modules/custom/3"/init.zsh
fi
EOF

  run zsh zimfw.zsh init
  assert_success
  assert_output ') modules/custom: Created'
  assert_file_exists "${ZIM_HOME}"/modules/custom/1/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/2/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/3/init.zsh
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh zimfw.zsh list -v
  assert_success
  assert_output "modules/custom: ${ZIM_HOME}/modules/custom
  From: mkdir
  On-pull: (builtin cd -q 1; >init.zsh <<<\"print \\\${CUSTOM1}\"); (builtin cd -q 2; >init.zsh <<<\"print custom2\"); (builtin cd -q 3; >init.zsh <<<\"print custom3\")
  Root: ${ZIM_HOME}/modules/custom/1
    if: [[ -n \${CUSTOM1} ]]
    cmd: source \"\${HOME}/.zim/modules/custom/1/init.zsh\"; print -R \"\${(F)\$(<\"\${HOME}/.zim/modules/custom/1\"/init.zsh)}\"
  Root: ${ZIM_HOME}/modules/custom/2
    cmd: source \"\${HOME}/.zim/modules/custom/2/init.zsh\"
  Root: ${ZIM_HOME}/modules/custom/3
    if: (( \${+commands[cat]} ))
    cmd: cat \"\${HOME}/.zim/modules/custom/3\"/init.zsh"

  CUSTOM1=custom1 run zsh -ic 'exit'
  # shellcheck disable=SC2016
  assert_output 'custom1
print ${CUSTOM1}
custom2
print custom3'

  cat >"${HOME}"/.zimrc <<EOF
zmodule custom --root 1 --use mkdir --on-pull 'rm -f init.zsh' -d
zmodule custom --root 2 --frozen --on-pull 'rm -f init.zsh'
zmodule custom --root 3 --on-pull 'rm -f init.zsh' --cmd 'cat {}/init.zsh'
zmodule custom --root 1 -c 'print -R "\${(F)\$(<{}/init.zsh)}"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/custom/2/init.zsh"
cat "\${HOME}/.zim/modules/custom/3"/init.zsh
EOF

  run zsh zimfw.zsh list -v
  assert_success
  assert_output "modules/custom: ${ZIM_HOME}/modules/custom (frozen)
  Root: ${ZIM_HOME}/modules/custom/1 (disabled)
  Root: ${ZIM_HOME}/modules/custom/2
    cmd: source \"\${HOME}/.zim/modules/custom/2/init.zsh\"
  Root: ${ZIM_HOME}/modules/custom/3
    cmd: cat \"\${HOME}/.zim/modules/custom/3\"/init.zsh"

  run zsh zimfw.zsh install -v
  assert_success
  assert_output ") modules/custom: Skipping frozen module
Done with install. Restart your terminal for changes to take effect.
) ${ZIM_HOME}/init.zsh: Updated
) ${ZIM_HOME}/login_init.zsh: Updated
Done with build. Restart your terminal for changes to take effect.
Done with compile."
  assert_file_exists "${ZIM_HOME}"/modules/custom/1/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/2/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/3/init.zsh
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh -ic 'exit'
  assert_output 'custom2
print custom3'
}
