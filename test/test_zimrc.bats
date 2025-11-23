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
  cat >"${HOME}"/.zshenv <<EOF
zstyle ':zim' disable-version-check yes
EOF
}

@test 'cannot init with empty .zimrc' {
  touch "${HOME}"/.zimrc

  run zsh "${PWD}"/zimfw.zsh init
  assert_failure
  assert_output "No modules defined in ${HOME}/.zimrc"
}

@test 'can configure path to .zimrc' {
  export ZIM_CONFIG_FILE="${HOME}"/.config/zsh/zimrc
  mkdir -p "$(dirname "${ZIM_CONFIG_FILE}")"
  cat >"${ZIM_CONFIG_FILE}" <<EOF
zmodule test --use mkdir --on-pull '>test.zsh <<<"print test"'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${ZIM_CONFIG_FILE}
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/.zim/modules/test/test.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh info
  assert_success
  assert_line "zimfw config:         ${ZIM_CONFIG_FILE}"

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_output ') modules/test: Created'
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh
}

@test 'can define function in .zimrc' {
  cat >"${HOME}"/.zimrc <<EOF
zmodule-eval() {
  local -r zcommand=\${\${=1}[1]} ztarget=\${1//[^[:alnum:]]/-}.zsh
  zmodule custom --root \${zcommand} --use mkdir --if-command \${zcommand} \
      --cmd "if [[ ! {}/\${ztarget} -nt \\\${commands[\${zcommand}]} ]]; then \${1} >! {}/\${ztarget}; zcompile -R {}/\${ztarget}; fi" \
      --source \${ztarget}
}
zmodule-eval 'zoxide init zsh'
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
if (( \${+commands[zoxide]} )); then
  if [[ ! "\${HOME}/.zim/modules/custom/zoxide"/zoxide-init-zsh.zsh -nt \${commands[zoxide]} ]]; then zoxide init zsh >! "\${HOME}/.zim/modules/custom/zoxide"/zoxide-init-zsh.zsh; zcompile -R "\${HOME}/.zim/modules/custom/zoxide"/zoxide-init-zsh.zsh; fi
  source "\${HOME}/.zim/modules/custom/zoxide/zoxide-init-zsh.zsh"
fi
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_output ') modules/custom: Created'
  assert_dir_exists "${ZIM_HOME}"/modules/custom/zoxide
  assert_file_not_exists "${ZIM_HOME}"/modules/custom/zoxide/zoxide-init-zsh.zsh
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list
  assert_success
  assert_output 'modules/custom'

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/custom
  From: mkdir
  Root: zoxide
    if: (( \${+commands[zoxide]} ))
    cmd: if [[ ! \"\${HOME}/.zim/modules/custom/zoxide\"/zoxide-init-zsh.zsh -nt \${commands[zoxide]} ]]; then zoxide init zsh >! \"\${HOME}/.zim/modules/custom/zoxide\"/zoxide-init-zsh.zsh; zcompile -R \"\${HOME}/.zim/modules/custom/zoxide\"/zoxide-init-zsh.zsh; fi; source \"\${HOME}/.zim/modules/custom/zoxide/zoxide-init-zsh.zsh\""
}

@test 'can create default .zimrc' {
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
fpath=("\${HOME}/.zim/modules/git/functions" "\${HOME}/.zim/modules/utility/functions" "\${HOME}/.zim/modules/duration-info/functions" "\${HOME}/.zim/modules/git-info/functions" "\${HOME}/.zim/modules/zsh-completions/src" "\${HOME}/.zim/modules/completion/functions" \${fpath})
autoload -Uz -- git-alias-lookup git-branch-current git-branch-delete-interactive git-branch-remote-tracking git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove mkcd mkpw duration-info-precmd duration-info-preexec coalesce git-action git-info
source "\${HOME}/.zim/modules/environment/init.zsh"
source "\${HOME}/.zim/modules/git/init.zsh"
source "\${HOME}/.zim/modules/input/init.zsh"
source "\${HOME}/.zim/modules/termtitle/init.zsh"
source "\${HOME}/.zim/modules/utility/init.zsh"
source "\${HOME}/.zim/modules/duration-info/init.zsh"
source "\${HOME}/.zim/modules/asciiship/asciiship.zsh-theme"
source "\${HOME}/.zim/modules/completion/init.zsh"
source "\${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "\${HOME}/.zim/modules/zsh-autosuggestions/zsh-autosuggestions.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_line --index 0 "Config file not found, will create ${HOME}/.zimrc"
  assert_line ') modules/environment: Installed'
  assert_line ') modules/git: Installed'
  assert_line ') modules/input: Installed'
  assert_line ') modules/termtitle: Installed'
  assert_line ') modules/utility: Installed'
  assert_line ') modules/duration-info: Installed'
  assert_line ') modules/git-info: Installed'
  assert_line ') modules/asciiship: Installed'
  assert_line ') modules/zsh-completions: Installed'
  assert_line ') modules/completion: Installed'
  assert_line ') modules/zsh-syntax-highlighting: Installed'
  assert_line ') modules/zsh-autosuggestions: Installed'
  assert_equal "${#lines[@]}" 13
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_output "modules/environment
  From: https://github.com/zimfw/environment.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/environment/init.zsh\"
modules/git
  From: https://github.com/zimfw/git.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/git/functions\"
  autoload: git-alias-lookup git-branch-current git-branch-delete-interactive git-branch-remote-tracking git-dir git-ignore-add git-root git-stash-clear-interactive git-stash-recover git-submodule-move git-submodule-remove
  cmd: source \"\${HOME}/.zim/modules/git/init.zsh\"
modules/input
  From: https://github.com/zimfw/input.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/input/init.zsh\"
modules/termtitle
  From: https://github.com/zimfw/termtitle.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/termtitle/init.zsh\"
modules/utility
  From: https://github.com/zimfw/utility.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/utility/functions\"
  autoload: mkcd mkpw
  cmd: source \"\${HOME}/.zim/modules/utility/init.zsh\"
modules/duration-info
  From: https://github.com/zimfw/duration-info.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/duration-info/functions\"
  autoload: duration-info-precmd duration-info-preexec
  cmd: source \"\${HOME}/.zim/modules/duration-info/init.zsh\"
modules/git-info
  From: https://github.com/zimfw/git-info.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/git-info/functions\"
  autoload: coalesce git-action git-info
modules/asciiship
  From: https://github.com/zimfw/asciiship.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/asciiship/asciiship.zsh-theme\"
modules/zsh-completions
  From: https://github.com/zsh-users/zsh-completions.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/zsh-completions/src\"
modules/completion
  From: https://github.com/zimfw/completion.git, default branch, using git
  fpath: \"\${HOME}/.zim/modules/completion/functions\"
  cmd: source \"\${HOME}/.zim/modules/completion/init.zsh\"
modules/zsh-syntax-highlighting
  From: https://github.com/zsh-users/zsh-syntax-highlighting.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"
modules/zsh-autosuggestions
  From: https://github.com/zsh-users/zsh-autosuggestions.git, default branch, using git
  cmd: source \"\${HOME}/.zim/modules/zsh-autosuggestions/zsh-autosuggestions.zsh\""
}
