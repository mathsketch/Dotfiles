if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
else
  echo 'direnv: command not found, please install it from https://direnv.net'
fi

