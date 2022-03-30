if (( $+commands[vivid] )); then
    export LS_COLORS="$(vivid generate $HOME/.config/vivid/theme/gruvbox.yml)"
else
  echo 'vivid: command not found, please install it from https://github.com/sharkdp/vivid'
fi

