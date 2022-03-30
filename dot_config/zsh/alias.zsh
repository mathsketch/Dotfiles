if command -v exa &>/dev/null;then
    alias ls="exa --icons --sort=type"
    alias la="exa --icons -a --sort=type"
    alias l="exa -la --sort=type"
    alias ll="exa -l --sort=type"
else
    alias ls="ls --color"
    alias la="ls -a --color"
    alias l="exa -la --color"
    alias ll="exa -l --color"
fi

alias todo='todo.sh'
alias pc="proxychains -q"
alias vimdiff="nvim -d"

alias cz="chezmoi"
alias czd="chezmoi cd"
alias czf="chezmoi diff"
alias czi="chezmoi edit"
