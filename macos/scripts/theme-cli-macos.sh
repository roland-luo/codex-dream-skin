#!/bin/bash

# Human-friendly terminal entry point for listing, selecting, advancing, and
# scheduling Codex Dream Skin themes.

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

usage() {
  /usr/bin/printf '%s\n' \
    'Usage:' \
    '  codex-dream-skin list' \
    '  codex-dream-skin use <theme-id|theme-name> [--restart]' \
    '  codex-dream-skin next' \
    '  codex-dream-skin auto on|off|status' \
    '  codex-dream-skin status' \
    '' \
    'Default switching is hot-only and never restarts Codex.' \
    'Pass --restart only when you explicitly want to authorize a restart.'
}

ensure_builtins() {
  local count=0 theme_id
  if [ -f "$BUILTIN_THEMES_MANIFEST" ]; then
    while IFS= read -r theme_id; do
      [ -f "$THEMES_ROOT/$theme_id/theme.json" ] && count=$((count + 1))
    done < <(/usr/bin/python3 - "$BUILTIN_THEMES_MANIFEST" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    for theme_id in json.load(f)["themes"]:
        print(theme_id)
PY
    )
  fi
  [ "$count" -eq 5 ] || "$SCRIPT_DIR/install-builtin-themes-macos.sh" --quiet
}

list_themes() {
  ensure_builtins
  /usr/bin/python3 - "$THEMES_ROOT" "$THEME_DIR/theme.json" "$BUILTIN_THEMES_MANIFEST" <<'PY'
import json, os, sys
themes_root, active_path, manifest_path = sys.argv[1:]
try:
    with open(active_path, encoding="utf-8") as f:
        active_id = json.load(f).get("id", "")
except Exception:
    active_id = ""
try:
    with open(manifest_path, encoding="utf-8") as f:
        order = json.load(f).get("themes", [])
except Exception:
    order = []
items = []
if os.path.isdir(themes_root):
    for entry in os.scandir(themes_root):
        config = os.path.join(entry.path, "theme.json")
        if not entry.is_dir() or not os.path.isfile(config):
            continue
        try:
            with open(config, encoding="utf-8") as f:
                theme = json.load(f)
            theme_id = str(theme.get("id") or entry.name)
            name = str(theme.get("name") or theme_id)
            items.append((theme_id, name))
        except Exception:
            continue
rank = {theme_id: index for index, theme_id in enumerate(order)}
items.sort(key=lambda item: (rank.get(item[0], len(rank)), item[1].casefold(), item[0]))
for theme_id, name in items:
    mark = "*" if theme_id == active_id else " "
    print(f"{mark} {theme_id:<20} {name}")
PY
}

resolve_theme_id() {
  local query="$1"
  if [ -f "$THEMES_ROOT/$query/theme.json" ]; then
    printf '%s' "$query"
    return 0
  fi
  /usr/bin/python3 - "$THEMES_ROOT" "$query" <<'PY'
import json, os, sys
root, query = sys.argv[1:]
matches = []
if os.path.isdir(root):
    for entry in os.scandir(root):
        config = os.path.join(entry.path, "theme.json")
        if not entry.is_dir() or not os.path.isfile(config):
            continue
        try:
            with open(config, encoding="utf-8") as f:
                theme = json.load(f)
            if theme.get("name") == query:
                matches.append(str(theme.get("id") or entry.name))
        except Exception:
            pass
if len(matches) != 1:
    raise SystemExit(1)
print(matches[0], end="")
PY
}

use_theme() {
  local query="${1:-}"
  local restart="false"
  local theme_id output result name
  [ -n "$query" ] || fail "Specify a theme ID or exact theme name. Run 'codex-dream-skin list' first."
  shift || true
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --restart) restart="true"; shift ;;
      *) fail "Unknown use option: $1" ;;
    esac
  done
  ensure_builtins
  theme_id="$(resolve_theme_id "$query")" || fail "Theme not found or name is ambiguous: $query"
  if [ "$restart" = "true" ]; then
    output="$("$SCRIPT_DIR/switch-theme-macos.sh" --id "$theme_id" --quiet)"
  else
    output="$("$SCRIPT_DIR/switch-theme-macos.sh" --id "$theme_id" --hot-only --quiet)"
  fi
  result="$(printf '%s\n' "$output" | /usr/bin/awk -F= '/^result=/{print $2; exit}')"
  name="$(printf '%s\n' "$output" | /usr/bin/awk -F= '/^theme=/{sub(/^theme=/, ""); print; exit}')"
  if [ "$result" = "applied" ]; then
    printf 'Switched to %s (%s).\n' "$name" "$theme_id"
  else
    printf 'Selected %s (%s); it will apply when the skin reconnects.\n' "$name" "$theme_id"
  fi
}

next_theme() {
  local output result name
  output="$("$SCRIPT_DIR/rotate-themes-macos.sh" --next --quiet)"
  result="$(printf '%s\n' "$output" | /usr/bin/awk -F= '/^result=/{print $2; exit}')"
  name="$(printf '%s\n' "$output" | /usr/bin/awk -F= '/^theme=/{sub(/^theme=/, ""); print; exit}')"
  if [ "$result" = "applied" ]; then
    printf 'Switched to %s.\n' "$name"
  else
    printf 'Selected %s; it will apply when the skin reconnects.\n' "$name"
  fi
}

command="${1:-help}"
shift || true
case "$command" in
  list) list_themes ;;
  use) use_theme "$@" ;;
  next) next_theme ;;
  auto)
    action="${1:-status}"
    case "$action" in
      on|enable) "$SCRIPT_DIR/rotate-themes-macos.sh" --enable --quiet ;;
      off|disable) "$SCRIPT_DIR/rotate-themes-macos.sh" --disable --quiet ;;
      status) "$SCRIPT_DIR/rotate-themes-macos.sh" --status ;;
      *) fail "Use: codex-dream-skin auto on|off|status" ;;
    esac
    ;;
  status)
    "$SCRIPT_DIR/status-dream-skin-macos.sh"
    "$SCRIPT_DIR/rotate-themes-macos.sh" --status
    ;;
  help|-h|--help) usage ;;
  *) use_theme "$command" "$@" ;;
esac
