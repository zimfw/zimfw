setup() {
  # shellcheck disable=SC2034
  BATS_LIB_PATH="${BATS_TEST_DIRNAME}"/test_helper
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file

  command -v git # assert git command installed
  assert_file_exists "${PWD}"/zimfw.zsh
  export HOME="${BATS_TEST_TMPDIR}"
  export ZIM_HOME="${HOME}"/.zim
  cat >"${HOME}"/.zshrc <<EOF
source ${ZIM_HOME}/init.zsh
EOF
}

@test 'can define module with roots' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule custom --root 1 --use mkdir --on-pull '>init.zsh <<<"print custom1"'
zmodule custom --root 2 --use mkdir --on-pull '>init.zsh <<<"print custom2"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/custom/1/init.zsh"
source "\${HOME}/.zim/modules/custom/2/init.zsh"
EOF

  run zsh zimfw.zsh init
  assert_success
  assert_output ') modules/custom: Created'
  assert_file_exists "${ZIM_HOME}"/modules/custom/1/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/2/init.zsh
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

}

