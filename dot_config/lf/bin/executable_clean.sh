#!/usr/bin/bash
thumbnail="$LF_CACHE/thumbnail.png"
cat <<-EOF | paste -sd '' >"$FIFO_UEBERZUG"
{
    "action": "remove",
    "identifier": "lf-preview"
}
EOF

if [[ -f "$thumbnail" ]];then
  rm $thumbnail
fi
