# lf cd
lfcd () {
    command -v lf >/dev/null || { echo "Not Found lf command!";exit 1; }
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

# set terminal network proxy
pxy () {
    proxy_file="${ZSHCACHE}/proxy"
    proxy_on() {
        if [ -f "$proxy_file" ];then
            proxy_value=$(cat "$proxy_file")
        else
            read -r "?Proxy Address: " proxy_value
            echo "$proxy_value" > "$proxy_file"
        fi
        if [ "$1" = "-g" ] && [ -n "$TMUX" ];then
            tmux setenv -g http_proxy $proxy_value  
            tmux setenv -g ftp_proxy $proxy_value   
            tmux setenv -g https_proxy $proxy_value 
            tmux setenv -g all_proxy $proxy_value   
            tmux setenv -g HTTP_PROXY $proxy_value  
            tmux setenv -g HTTPS_PROXY $proxy_value 
            tmux setenv -g FTP_PROXY $proxy_value   
            tmux setenv -g ALL_PROXY $proxy_value
            tmux setenv -g no_proxy "localhost,127.0.0.1,localaddress,.localdomain.com"
            tmux set -g @tmux-proxy-status 1
            echo -e "tmux proxy on!"
        fi
        export http_proxy=$proxy_value  \
            ftp_proxy=$proxy_value   \
            https_proxy=$proxy_value \
            all_proxy=$proxy_value   \
            HTTP_PROXY=$proxy_value  \
            HTTPS_PROXY=$proxy_value \
            FTP_PROXY=$proxy_value   \
            ALL_PROXY=$proxy_value
                    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
                    echo -e "proxy on!"
    }
    proxy_off() {
        if [ "$1" = "-g" ] && [ -n "$TMUX" ];then
            tmux setenv -ug http_proxy
            tmux setenv -ug ftp_proxy
            tmux setenv -ug https_proxy
            tmux setenv -ug all_proxy
            tmux setenv -ug HTTP_PROXY
            tmux setenv -ug HTTPS_PROXY
            tmux setenv -ug FTP_PROXY
            tmux setenv -ug ALL_PROXY
            tmux setenv -ug no_proxy
            tmux set -g @tmux-proxy-status 0
            echo -e "tmux proxy off!"
        fi
        unset http_proxy ftp_proxy https_proxy all_proxy \
              HTTP_PROXY HTTPS_PROXY FTP_PROXY ALL_PROXY
        echo -e "proxy off!"
    }
    case $1 in
        on) shift; proxy_on "$@";;
        off) shift; proxy_off "$@";;
        cls) proxy_off -g; [ -f "$proxy_file" ] && rm "$proxy_file" ;;
        *) echo -e "usage: pxy cls/on/off [-g]" ;;
    esac
}
