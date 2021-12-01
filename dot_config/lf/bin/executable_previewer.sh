#!/usr/bin/bash

preview() {
    x=$4; y=$5; w=$(($2-1)); h=$3
    [ -z "$TMUX" ] || y=$(($y+1))
    cat <<-EOF | paste -sd '' >"$FIFO_UEBERZUG"
    {
        "action": "add", "identifier": "lf-preview",
        "path": "$1", "x": $x, "y": $y, "width": $w, "height": $h,
        "scaler": "contain",
        "scaling_position_y": 0.5,
        "scaling_position_x": 0.5 
    }
EOF
}

"$CONFIG_BIN"/clean.sh

file="$1"; shift
thumbnail="$LF_CACHE/thumbnail.png"
case "$(basename "$file" | tr '[:upper:]' '[:lower:]')" in
    *.tar*) tar tf "$file" ;;
    *.zip) unzip -l "$file" ;;
    *.rar) unrar l "$file" ;;
    *.7z) 7z l "$file" ;;
    *.avi|*.mp4|*.mkv|*.flv)
        ffmpeg -y -i "$file" -ss '00:00:05' -vframes 1 "$thumbnail"
        preview "$thumbnail" "$@"
        ;;
    *.pdf)
        gs -o "$thumbnail" -sDEVICE=pngalpha -dLastPage=1 "$file" >/dev/null
        preview "$thumbnail" "$@"
        ;;
    *.jpg|*.jpeg|*.png|*.bmp|*.tga)
        preview "$file" "$@" ;;
    *.svg)
        gm convert "$file" "$thumbnail"
        preview "$thumbnail" "$@"
        ;;
    *.gif)
        gm convert "${file[0]}" "$thumbnail"
        preview "$thumbnail" "$@"
        ;;
    *.md|*.markdown) glow "$file";;
    *.iso|*.img) ;;
    *) bat "$file" -p -n --color=always;;
esac
exit 1
