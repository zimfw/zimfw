# vim:et sts=2 sw=2 ft=zsh
#
# Gitster theme
# https://github.com/shashankmehta/dotfiles/blob/master/thesetup/zsh/.oh-my-zsh/custom/themes/gitster.zsh-theme
#
# Requires the `git-info` zmodule to be included in the .zimrc file.

prompt_gitster_pwd() {
  prompt_short_dir=$(short_pwd)
  git_root=$(command git rev-parse --show-toplevel 2> /dev/null) && prompt_short_dir=${prompt_short_dir#${$(short_pwd $git_root):h}/}
  print -n "%F{white}${prompt_short_dir}"
}

prompt_gitster_git() {
  [[ -n ${git_info} ]] && print -n "${(e)git_info[prompt]}"
}

prompt_gitster_precmd() {
  (( ${+functions[git-info]} )) && git-info
}

prompt_gitster_setup() {
  local prompt_gitster_status='%(?:%F{green}:%F{red})➜ '

  autoload -Uz add-zsh-hook && add-zsh-hook precmd prompt_gitster_precmd

  prompt_opts=(cr percent sp subst)

  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:clean' format '%F{green}✓'
  zstyle ':zim:git-info:dirty' format '%F{yellow}✗'
  zstyle ':zim:git-info:keys' format \
    'prompt' ' %F{cyan}%b%c %C%D'

  PS1="${prompt_gitster_status}\$(prompt_gitster_pwd)\$(prompt_gitster_git)%f "
  RPS1=''
}

prompt_gitster_setup "${@}"
