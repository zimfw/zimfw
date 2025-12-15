setup() {
  # shellcheck disable=SC2034
  BATS_LIB_PATH="${BATS_TEST_DIRNAME}"/test_helper
  bats_load_library setup_all
  setup_all
}

@test 'can define module with roots' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule custom --use mkdir --on-pull '>custom.zsh <<<"print custom"'
zmodule custom --root 1 --on-pull '>custom.zsh <<<"print custom1"'
zmodule custom --root 2 --on-pull '>custom.zsh <<<"print custom2"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/custom/custom.zsh"
source "\${HOME}/.zim/modules/custom/1/custom.zsh"
source "\${HOME}/.zim/modules/custom/2/custom.zsh"
EOF

  run zsh zimfw.zsh init
  assert_success
  assert_output ') modules/custom: Created'
  assert_file_exists "${ZIM_HOME}"/modules/custom/custom.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/1/custom.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom/2/custom.zsh
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh zimfw.zsh list -v
  assert_success
  assert_output "modules/custom
  From: mkdir
  On-pull: >custom.zsh <<<\"print custom\"; (builtin cd -q 1; >custom.zsh <<<\"print custom1\"); (builtin cd -q 2; >custom.zsh <<<\"print custom2\")
  Root: .
    cmd: source \"\${HOME}/.zim/modules/custom/custom.zsh\"
  Root: 1
    cmd: source \"\${HOME}/.zim/modules/custom/1/custom.zsh\"
  Root: 2
    cmd: source \"\${HOME}/.zim/modules/custom/2/custom.zsh\""
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
  assert_output "modules/custom
  From: mkdir
  On-pull: (builtin cd -q 1; >init.zsh <<<\"print \\\${CUSTOM1}\"); (builtin cd -q 2; >init.zsh <<<\"print custom2\"); (builtin cd -q 3; >init.zsh <<<\"print custom3\")
  Root: 1
    if: [[ -n \${CUSTOM1} ]]
    cmd: source \"\${HOME}/.zim/modules/custom/1/init.zsh\"; print -R \"\${(F)\$(<\"\${HOME}/.zim/modules/custom/1\"/init.zsh)}\"
  Root: 2
    cmd: source \"\${HOME}/.zim/modules/custom/2/init.zsh\"
  Root: 3
    if: (( \${+commands[cat]} ))
    cmd: cat \"\${HOME}/.zim/modules/custom/3\"/init.zsh"

  CUSTOM1=custom1 run zsh -ic 'exit'
  assert_success
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
  assert_output "modules/custom (frozen)
  Root: 1 (disabled)
  Root: 2
    cmd: source \"\${HOME}/.zim/modules/custom/2/init.zsh\"
  Root: 3
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
  assert_success
  assert_output 'custom2
print custom3'
}

@test 'can strip slashes from names and roots' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule ignoreprefix/custom1/ --root / --use mkdir --on-pull '>init.zsh <<<"print custom1"'
zmodule ignoreprefix/custom1/ --root /1/ --on-pull '>1.zsh <<<"print custom1_1"'
zmodule ignoreprefix/custom1/ --root /2/ --on-pull '>2.zsh <<<"print custom1_2"'
zmodule ignoreurl/ --name /tmp/custom2/ --use mkdir --on-pull '>custom2.zsh <<<"print custom2"'
zmodule https://ignoreurl/ --name /tmp/custom3/  --root 1/ --use mkdir --on-pull '>custom3.zsh <<<"print custom3_1"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/custom1/init.zsh"
source "\${HOME}/.zim/modules/custom1/1/1.zsh"
source "\${HOME}/.zim/modules/custom1/2/2.zsh"
source "\${HOME}/.zim/modules/tmp/custom2/custom2.zsh"
source "\${HOME}/.zim/modules/tmp/custom3/1/custom3.zsh"
EOF

  run zsh zimfw.zsh install
  assert_success
  assert_line ') modules/custom1: Created'
  assert_line ') modules/tmp/custom2: Created'
  assert_line ') modules/tmp/custom3: Created'
  assert_line --index 3 'Done with install. Restart your terminal for changes to take effect.'
  assert_equal "${#lines[@]}" 4
  assert_file_exists "${ZIM_HOME}"/modules/custom1/init.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom1/1/1.zsh
  assert_file_exists "${ZIM_HOME}"/modules/custom1/2/2.zsh
  assert_file_exists "${ZIM_HOME}"/modules/tmp/custom2/custom2.zsh
  assert_file_exists "${ZIM_HOME}"/modules/tmp/custom3/1/custom3.zsh
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh zimfw.zsh list
  assert_success
  assert_output "modules/custom1
modules/tmp/custom2
modules/tmp/custom3"

  run zsh zimfw.zsh list -v
  assert_success
  assert_output "modules/custom1
  From: mkdir
  On-pull: >init.zsh <<<\"print custom1\"; (builtin cd -q 1; >1.zsh <<<\"print custom1_1\"); (builtin cd -q 2; >2.zsh <<<\"print custom1_2\")
  Root: .
    cmd: source \"\${HOME}/.zim/modules/custom1/init.zsh\"
  Root: 1
    cmd: source \"\${HOME}/.zim/modules/custom1/1/1.zsh\"
  Root: 2
    cmd: source \"\${HOME}/.zim/modules/custom1/2/2.zsh\"
modules/tmp/custom2
  From: mkdir
  On-pull: >custom2.zsh <<<\"print custom2\"
  cmd: source \"\${HOME}/.zim/modules/tmp/custom2/custom2.zsh\"
modules/tmp/custom3
  From: mkdir
  On-pull: (builtin cd -q 1; >custom3.zsh <<<\"print custom3_1\")
  Root: 1
    cmd: source \"\${HOME}/.zim/modules/tmp/custom3/1/custom3.zsh\""
}

@test 'can define external module with roots' {
  mkdir -p "${HOME}"/external/{1,2}
  touch "${HOME}"/external/{1,2}/external.zsh
  cat >"${HOME}"/.zimrc <<EOF
zmodule ${HOME}/external --root 1
zmodule ${HOME}/external --root 2
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/external/1/external.zsh"
source "\${HOME}/external/2/external.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_output ''
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

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
  From: ${HOME}/external
  Root: 1
    cmd: source \"\${HOME}/external/1/external.zsh\"
  Root: 2
    cmd: source \"\${HOME}/external/2/external.zsh\""
}
