#!/usr/bin/env bash
# Opens a new "read" (or "read-2", "read-3", etc.) Herdr tab positioned
# right after the triggering Neovim tab, and renders the given markdown file into it via markdown-reader.sh.
set -euo pipefail

OUT="${1:?usage: open-reader-tab.sh <markdown-file>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
READER="$SCRIPT_DIR/markdown-reader.sh"
TAB_MOVE="$SCRIPT_DIR/herdr-tab-move.py"
PREFIX="read"

# 1. Resolve which workspace this process belongs to
ws_id="${HERDR_WORKSPACE_ID:-}"

if [ -z "$ws_id" ] && [ -n "${HERDR_TAB_ID:-}" ]; then
  ws_id="${HERDR_TAB_ID%%:*}"
fi

if [ -z "$ws_id" ] && [ -n "${HERDR_PANE_ID:-}" ]; then
  ws_id="${HERDR_PANE_ID%%:*}"
fi

if [ -z "$ws_id" ]; then
  ws_id="$(herdr pane list 2>/dev/null | jq -r --arg cwd "$PWD" '.result.panes[] | select(.cwd==$cwd) | .workspace_id' | head -1)"
fi

if [ -z "$ws_id" ]; then
  ws_id="$(herdr workspace list 2>/dev/null | jq -r '.result.workspaces[] | select(.focused==true) | .workspace_id' | head -1)"
fi

if [ -z "$ws_id" ]; then
  echo "Failed to resolve workspace ID" >&2
  exit 1
fi

# 2. Determine target label (read, read-2, read-3, etc.)
tab_list="$(herdr tab list --workspace "$ws_id" 2>/dev/null)"
target_label="$(echo "$tab_list" | jq -r --arg pfx "$PREFIX" '
  [ .result.tabs[]?.label // empty ] as $labels
  | if ($labels | index($pfx)) == null then
      $pfx
    else
      first(range(2; 1000) | "\($pfx)-\(.)" | select(IN($labels[]) | not))
    end
')"

if [ -z "$target_label" ] || [ "$target_label" = "null" ]; then
  target_label="$PREFIX"
fi

# 3. Create the new reader tab
result="$(herdr tab create --workspace "$ws_id" --label "$target_label" --cwd "$PWD" --no-focus 2>/dev/null)"
target_tab_id="$(echo "$result" | jq -r '.result.tab.tab_id')"
pane_id="$(echo "$result" | jq -r '.result.root_pane.pane_id')"

if [ -z "$pane_id" ] || [ "$pane_id" = "null" ] || [ -z "$target_tab_id" ] || [ "$target_tab_id" = "null" ]; then
  echo "Failed to create reader tab in workspace $ws_id" >&2
  exit 1
fi

# 4. Position right after the triggering Neovim tab
current_idx="$(echo "$tab_list" | jq -r --arg tid "${HERDR_TAB_ID:-}" '.result.tabs | to_entries[] | select(.value.tab_id==$tid) | .key' | head -1)"
if [ -z "$current_idx" ]; then
  current_idx="$(echo "$tab_list" | jq -r '.result.tabs | to_entries[] | select(.value.focused==true) | .key' | head -1)"
fi

if [ -n "$current_idx" ] && [ -f "$TAB_MOVE" ]; then
  tab_count="$(echo "$tab_list" | jq -r '.result.tabs | length')"
  tab_count=$((tab_count + 1))
  insert_idx=$((current_idx + 1))
  if [ "$insert_idx" -ge "$tab_count" ]; then
    insert_idx=$((tab_count - 1))
  fi
  python3 "$TAB_MOVE" "$target_tab_id" "$insert_idx" >/dev/null 2>&1 || true
fi

# 5. Focus reader tab and run reader
herdr tab focus "$target_tab_id" >/dev/null 2>&1 || true
sleep 0.05

quoted_out="$(printf '%q' "$OUT")"
herdr pane run "$pane_id" "$READER $quoted_out" >/dev/null 2>&1 || true
exit 0
