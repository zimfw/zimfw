setup() {
  BATS_LIB_PATH=${BATS_TEST_DIRNAME}/test_helper
  bats_load_library bats-support
  bats_load_library bats-assert
  bats_load_library bats-file

  assert_file_exists ${PWD}/zimfw.zsh
  export HOME=${BATS_TEST_TMPDIR}
  export ZIM_HOME=${HOME}/.zim
}

_test_submodules() {
  if [[ -z ${USE_DEGIT} ]]; then
    command -v git # assert git command installed
  else
    cat >${HOME}/expected_zdegit <<EOF
https://github.com/spaceship-prompt/spaceship-prompt.git
v3.13.3
If-None-Match: "c8064a1deeb1585a09d77e8dc30c8a209b60ec093b2a3868a06a2c1411bf8ebf"
EOF
  fi
  cat >${HOME}/.zimrc <<EOF
zmodule spaceship-prompt/spaceship-prompt --name spaceship --tag v3.13.3 ${USE_DEGIT} ${NO_SUBMODULES}
EOF
  cat >${HOME}/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/spaceship/spaceship.zsh"
EOF

  run zsh ${PWD}/zimfw.zsh init
  assert_success
  if [[ -n ${USE_DEGIT} && -z ${NO_SUBMODULES} ]]; then
    assert_output ") modules/spaceship: Installed
! modules/spaceship: Module contains git submodules, which are not supported by zimfw's degit. Use zmodule option --no-submodules to stop this warning."
  else
    assert_output ') modules/spaceship: Installed'
  fi
  if [[ -z ${USE_DEGIT} ]]; then
    assert_exists ${ZIM_HOME}/modules/spaceship/.git
    assert_equal $(git -C ${ZIM_HOME}/modules/spaceship rev-parse HEAD) bdb247d84cffc0c068e2370dabcce29c3b671607
  else
    assert_exists ${ZIM_HOME}/modules/spaceship/.zdegit
    assert_files_equal ${ZIM_HOME}/modules/spaceship/.zdegit ${HOME}/expected_zdegit
  fi
  if [[ -z ${USE_DEGIT} && -z ${NO_SUBMODULES} ]]; then
    assert_exists ${ZIM_HOME}/modules/spaceship/tests/shunit2/.git
  else
    assert_not_exists ${ZIM_HOME}/modules/spaceship/tests/shunit2/.git
  fi
  assert_file_exists ${ZIM_HOME}/modules/spaceship/spaceship.zsh
  assert_file_exists ${ZIM_HOME}/modules/spaceship/spaceship.zsh.zwc
  assert_files_equal ${ZIM_HOME}/init.zsh ${HOME}/expected_init.zsh
}

@test 'can install submodules' {
  USE_DEGIT= NO_SUBMODULES= _test_submodules
}

@test 'can skip submodules' {
  USE_DEGIT= NO_SUBMODULES=--no-submodules _test_submodules
}

@test 'can use degit' {
  USE_DEGIT='--use degit' NO_SUBMODULES= _test_submodules
}

@test 'can skip submodules using degit' {
  USE_DEGIT='--use degit' NO_SUBMODULES=--no-submodules _test_submodules
}
