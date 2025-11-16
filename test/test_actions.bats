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

@test 'can print info' {
  run zsh "${PWD}"/zimfw.zsh info
  assert_success
  assert_line "ZIM_HOME:             ${ZIM_HOME}"
  assert_line "zimfw config:         ${HOME}/.zimrc"
  assert_line "zimfw script:         ${PWD}/zimfw.zsh"
}

@test 'can print info with symlinks' {
  mkdir -p "${HOME}"/dotfiles/zim
  touch "${HOME}"/dotfiles/zimrc
  ln -s "${HOME}"/dotfiles/zim "${HOME}"/.zim
  ln -s "${HOME}"/dotfiles/zimrc "${HOME}"/.zimrc
  ln -s "${PWD}"/zimfw.zsh "${HOME}"/zimfw.zsh
  REAL_HOME="$(realpath "${HOME}")"
  run zsh "${HOME}"/zimfw.zsh info
  assert_success
  assert_line "ZIM_HOME:             ${HOME}/.zim -> ${REAL_HOME}/dotfiles/zim"
  assert_line "zimfw config:         ${HOME}/.zimrc -> ${REAL_HOME}/dotfiles/zimrc"
  assert_line "zimfw script:         ${HOME}/zimfw.zsh -> ${PWD}/zimfw.zsh"
}

@test 'can turn script path to absolute path' {
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
