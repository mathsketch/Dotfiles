if (( $+commands[starship] )); then
    eval $(starship init zsh)
else
  echo 'starship: command not found, please install it from https://starship.rs'
fi
