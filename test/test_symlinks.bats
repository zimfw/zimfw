setup() {
  load test_helper/setup_all
  setup_all
}

@test 'keeps symlinks and ../ segments unresolved in init.zsh' {
  mkdir -p "${HOME}"/real/plugins/plugin "${HOME}"/real/lib
  echo 'print real-lib' >"${HOME}"/real/lib/lib.zsh
  ln -s real/plugins/plugin "${HOME}"/plugin
  cat >"${HOME}"/.zimrc <<EOF
zmodule ${HOME}/plugin -s ../../lib/lib.zsh
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
source "\${HOME}/plugin/../../lib/lib.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh

  run zsh -c "source ${ZIM_HOME}/init.zsh"
  assert_success
  assert_output 'real-lib'
}

@test 'only replaces HOME at the start of paths in init.zsh' {
  mkdir -p "${HOME}/sub${HOME}"/external/functions
  touch "${HOME}/sub${HOME}"/external/{external.zsh,functions/foo}
  cat >"${HOME}"/.zimrc <<EOF
zmodule ${HOME}/sub${HOME}/external
EOF
  cat >"${HOME}"/expected_init.zsh <<EOF
# FILE AUTOMATICALLY GENERATED FROM ${HOME}/.zimrc
# EDIT THE SOURCE FILE AND THEN RUN zimfw build. DO NOT DIRECTLY EDIT THIS FILE!

if [[ -e \${ZIM_CONFIG_FILE:-\${ZDOTDIR:-\${HOME}}/.zimrc} ]] zimfw() { source "${PWD}/zimfw.zsh" "\${@}" }
fpath=("\${HOME}/sub${HOME}/external/functions" \${fpath})
autoload -Uz -- foo
source "\${HOME}/sub${HOME}/external/external.zsh"
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_files_equal "${ZIM_HOME}"/init.zsh "${HOME}"/expected_init.zsh
}

@test 'can detect module files through symlinks' {
  mkdir -p "${HOME}"/shared/functions "${HOME}"/external/{a,b}
  touch "${HOME}"/shared/functions/foo
  ln -s ../../shared/functions "${HOME}"/external/a/functions
  # Sizes in bytes: b.plugin.zsh symlink itself (20) < b.zsh (25) < symlink target (29)
  echo 'print shared-big-file-target' >"${HOME}"/shared/big.zsh
  echo 'print small-regular-file' >"${HOME}"/external/b/b.zsh
  ln -s ../../shared/big.zsh "${HOME}"/external/b/b.plugin.zsh
  cat >"${HOME}"/.zimrc <<EOF
zmodule ${HOME}/external/a
zmodule ${HOME}/external/b
EOF

  run zsh "${PWD}"/zimfw.zsh list -v
  assert_success
  assert_line "  fpath: \"\${HOME}/external/a/functions\""
  assert_line '  autoload: foo'
  assert_line "  cmd: source \"\${HOME}/external/b/b.plugin.zsh\""
}

@test 'can clean compiled files through symlinks' {
  mkdir -p "${HOME}"/elsewhere/{foo,root} "${ZIM_HOME}"/modules "${HOME}"/external
  echo 'print foo' >"${HOME}"/elsewhere/foo/foo.zsh
  ln -s ../../elsewhere/foo "${ZIM_HOME}"/modules/foo
  echo 'print root' >"${HOME}"/elsewhere/root/root.zsh
  ln -s ../elsewhere/root "${HOME}"/external/root
  cat >"${HOME}"/.zimrc <<EOF
zmodule foo --frozen
zmodule ${HOME}/external --root root
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success
  assert_file_exists "${HOME}"/elsewhere/foo/foo.zsh.zwc
  assert_file_exists "${HOME}"/elsewhere/root/root.zsh.zwc

  run zsh "${PWD}"/zimfw.zsh clean-compiled
  assert_success
  assert_file_not_exists "${HOME}"/elsewhere/foo/foo.zsh.zwc
  assert_file_not_exists "${HOME}"/elsewhere/root/root.zsh.zwc
}

@test 'does not uninstall module used via another path' {
  mkdir -p "${HOME}"/dotfiles/zim
  ln -s dotfiles/zim "${ZIM_HOME}"
  cat >"${HOME}"/.zimrc <<EOF
zmodule test --use mkdir --on-pull '>test.zsh <<<"print test"'
EOF

  run zsh "${PWD}"/zimfw.zsh init
  assert_success

  cat >"${HOME}"/.zimrc <<EOF
zmodule ${HOME}/dotfiles/zim/modules/test --name other
EOF
  run zsh "${PWD}"/zimfw.zsh uninstall -q
  assert_success
  assert_file_exists "${HOME}"/dotfiles/zim/modules/test/test.zsh
}
