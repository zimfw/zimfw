# shellcheck disable=SC2030,SC2031
setup() {
  # shellcheck disable=SC2034
  BATS_LIB_PATH="${BATS_TEST_DIRNAME}"/test_helper
  bats_load_library setup_all
  setup_all
}

@test 'can configure ZIM_HOME outside HOME' {
  # shellcheck disable=SC2030
  ZIM_HOME="${BATS_TMPDIR}/.zim_$$_${RANDOM}"
  cat >"${HOME}"/.zshrc <<EOF
source ${ZIM_HOME}/init.zsh
EOF
  cat >"${HOME}"/.zimrc <<EOF
zmodule custom --use mkdir --on-pull '>init.zsh <<<"print init"; mkdir functions; >functions/custom <<<"print custom"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
fpath=("${ZIM_HOME}/modules/custom/functions" \${fpath})
autoload -Uz -- custom
source "${ZIM_HOME}/modules/custom/init.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh info
  assert_success
  assert_line "ZIM_HOME:             ${ZIM_HOME}"

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_output ') modules/custom: Created'
  assert_file_exists "${ZIM_HOME}"/modules/custom/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/functions/custom
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/custom
  From: mkdir
  On-pull: >init.zsh <<<\"print init\"; mkdir functions; >functions/custom <<<\"print custom\"
  fpath: \"${ZIM_HOME}/modules/custom/functions\"
  autoload: custom
  cmd: source \"${ZIM_HOME}/modules/custom/init.zsh\""

  run zsh -ic 'custom'
  assert_success
  assert_output "init
custom"
}
