#!/usr/bin/env bash
# Markdown terminal reader for Neovim (Space + r + d)
# Renders markdown using glow and less, with in-place 'r' refresh and centered layout.
set -euo pipefail

file="${1:?usage: markdown-reader.sh <markdown-file>}"

rendered="$(mktemp -t nvim-read-rendered)"
keyfile="$(mktemp -t nvim-read-lesskey)"
trap 'rm -f "$rendered" "${rendered}.tmp" "$keyfile"' EXIT

# Map 'r' and 'R' to reload (exit less with status 82 'R')
cat << 'KEYEOF' > "$keyfile"
#command
r quit R
R quit R
KEYEOF

get_cols() {
  local c
  # stty size via stderr (fd 2) queries the active terminal window size
  c="$(stty size 0<&2 2>/dev/null | awk '{print $2}')"
  if [ -z "$c" ] || [ "$c" -le 0 ] 2>/dev/null; then
    c="$(tput cols 2>/dev/null || echo 80)"
  fi
  if [ -z "$c" ] || [ "$c" -le 0 ] 2>/dev/null; then
    c=80
  fi
  echo "$c"
}

render_doc() {
  local cols target_width min_width max_width content_width margin
  cols="$(get_cols)"

  target_width=86
  min_width=40
  max_width=90
  [ "$target_width" -gt "$max_width" ] && target_width=$max_width

  content_width=$target_width
  if [ "$cols" -lt $((content_width + 6)) ]; then
    content_width=$((cols - 4))
    [ "$content_width" -lt "$min_width" ] && content_width=$min_width
  fi

  margin=$(( (cols - content_width) / 2 ))
  [ "$margin" -lt 0 ] && margin=0

  local tmp_render="${rendered}.tmp"
  if {
    printf '\n\n\n'
    glow -s tokyo-night -w "$content_width" "$file" < /dev/null \
      | perl -pe 's/\x1b\[38;2;169;177;214m/\x1b[38;2;255;255;255m/g' \
      | MARGIN="$margin" perl -ne '
          BEGIN { $m = $ENV{MARGIN}; $first = 1; $prev_blank = 0; }
          chomp;
          (my $stripped = $_) =~ s/\x1b\[[0-9;]*m//g;
          my $is_bullet = ($stripped =~ /^[ \t]*(\xe2\x80\xa2|\d+\.)[ \t]/);
          if ($is_bullet && !$first && !$prev_blank) {
            print((" " x $m), "\n");
          }
          print((" " x $m), $_, "\n");
          $prev_blank = ($stripped =~ /^[ \t]*$/);
          $first = 0;
        '
    printf '\n\n'
  } > "$tmp_render" 2>/dev/null; then
    mv "$tmp_render" "$rendered"
  else
    rm -f "$tmp_render"
  fi

  # glow queries the terminal directly via /dev/tty for capability detection;
  # drain any stray response bytes so less doesn't read them as keystrokes.
  while read -r -t 0.05 -n 1 -s _ < /dev/tty 2>/dev/null; do :; done
}

while true; do
  render_doc

  set +e
  less -R -~ -P ' ' --lesskey-src="$keyfile" "$rendered"
  rc=$?
  set -e

  # If exited via 'r' or 'R' (code 82), loop and re-render
  if [ "$rc" -eq 82 ]; then
    continue
  fi

  # Exit on 'q' or any other signal
  break
done
