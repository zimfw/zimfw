setup() {
  # shellcheck disable=SC2034
  BATS_LIB_PATH="${BATS_TEST_DIRNAME}"/test_helper
  bats_load_library setup_all
  setup_all
}

_test_submodules() {
  local -r repo="${FIXTURES_DIR}"/github.com/spaceship-prompt/spaceship-prompt.git
  create_repo github.com/kward/shunit2.git shunit2
  create_repo github.com/spaceship-prompt/spaceship-prompt.git spaceship.zsh
  git -C "${repo}" submodule add -q https://github.com/kward/shunit2.git tests/shunit2
  git -C "${repo}" commit -qm 'Add shunit2 submodule'
  git -C "${repo}" tag v3.13.3
  git -C "${repo}" commit -q --allow-empty -m 'Commit after tag' # so tag_sha is not the last commit sha
  local -r tag_sha="$(git -C "${repo}" rev-parse 'v3.13.3^{commit}')"
  cat >"${HOME}"/.zimrc <<EOF
zmodule spaceship-prompt/spaceship-prompt --name spaceship --tag v3.13.3 ${USE_DEGIT} ${NO_SUBMODULES}
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/spaceship/spaceship.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  if [[ -n ${USE_DEGIT} && -z ${NO_SUBMODULES} ]]; then
    assert_output ") modules/spaceship: Installed
! modules/spaceship: Module contains git submodules, which are not supported by zimfw's degit. Use zmodule option --no-submodules to stop this warning."
  else
    assert_output ') modules/spaceship: Installed'
  fi
  if [[ -z ${USE_DEGIT} ]]; then
    assert_exists "${ZIM_HOME}"/modules/spaceship/.git
    assert_equal "$(git -C "${ZIM_HOME}"/modules/spaceship rev-parse HEAD)" "${tag_sha}"
  else
    cat >"${HOME}"/expected_zdegit <<EOF
https://github.com/spaceship-prompt/spaceship-prompt.git
v3.13.3
If-None-Match: "${tag_sha}"
EOF
    assert_exists "${ZIM_HOME}"/modules/spaceship/.zdegit
    assert_files_equal "${ZIM_HOME}"/modules/spaceship/.zdegit "${HOME}"/expected_zdegit
  fi
  if [[ -z ${USE_DEGIT} && -z ${NO_SUBMODULES} ]]; then
    assert_exists "${ZIM_HOME}"/modules/spaceship/tests/shunit2/.git
  else
    assert_not_exists "${ZIM_HOME}"/modules/spaceship/tests/shunit2/.git
  fi
  assert_file_exists "${ZIM_HOME}"/modules/spaceship/spaceship.zsh
  assert_file_exists "${ZIM_HOME}"/modules/spaceship/spaceship.zsh.zwc
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh
}

@test 'can install submodules' {
  USE_DEGIT='' NO_SUBMODULES='' _test_submodules
}

@test 'can skip submodules' {
  USE_DEGIT='' NO_SUBMODULES=--no-submodules _test_submodules
}

@test 'cannot install submodules using degit' {
  USE_DEGIT='--use degit' NO_SUBMODULES='' _test_submodules
}

@test 'can skip submodules using degit' {
  USE_DEGIT='--use degit' NO_SUBMODULES=--no-submodules _test_submodules
}
