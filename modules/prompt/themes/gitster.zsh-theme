#
# Gitster theme
# https://github.com/shashankmehta/dotfiles/blob/master/thesetup/zsh/.oh-my-zsh/custom/themes/gitster.zsh-theme
#

prompt_gitster_get_status() {
  print '%(?:%F{green}➜:%F{red}➜) '
}

prompt_gitster_get_pwd() {
  prompt_short_dir=$(short_pwd)
  git_root=$(command git rev-parse --show-toplevel 2> /dev/null) && prompt_short_dir=${prompt_short_dir#${$(short_pwd $git_root):h}/}
  print ${prompt_short_dir}
}

prompt_gitster_precmd() {
  [[ ${+functions[git-info]} ]] && git-info
}

prompt_gitster_setup() {
  autoload -Uz colors && colors
  autoload -Uz add-zsh-hook

  prompt_opts=(cr percent subst)

  add-zsh-hook precmd prompt_gitster_precmd

  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:clean' format '%F{green}✓'
  zstyle ':zim:git-info:dirty' format '%F{yellow}✗'
  zstyle ':zim:git-info:keys' format \
    'prompt' ' %F{cyan}%b%c %C%D'

  PROMPT='$(prompt_gitster_get_status)%F{white}$(prompt_gitster_get_pwd)${(e)git_info[prompt]}%f '
  RPROMPT=''
}

prompt_gitster_setup "$@"
