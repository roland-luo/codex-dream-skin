#!/bin/bash

# Switch to a theme pack under themes/<id>. The hot-only mode is used by the
# timer and menu bar so theme changes never restart Codex without confirmation.

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

THEME_ID=""
APPLY_NOW="true"
HOT_ONLY="false"
QUIET="false"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --id) THEME_ID="${2:-}"; shift 2 ;;
    --no-apply) APPLY_NOW="false"; shift ;;
    --hot-only) HOT_ONLY="true"; shift ;;
    --quiet) QUIET="true"; shift ;;
    *) fail "Unknown argument: $1" ;;
  esac
done

[ -n "$THEME_ID" ] || fail "Usage: switch-theme-macos.sh --id <theme-id>"
case "$THEME_ID" in *[!a-z0-9-]*|'') fail "Invalid theme id: $THEME_ID" ;; esac

ensure_state_root
SRC="$THEMES_ROOT/$THEME_ID"
[ -d "$SRC" ] || fail "Theme not found: $THEME_ID"
[ -f "$SRC/theme.json" ] || fail "theme.json missing in $THEME_ID"

progress() {
  [ "$QUIET" = "true" ] && return 0
  printf '%s\n' "$*" >&2
  /usr/bin/osascript -e "display notification \"$*\" with title \"Codex Dream Skin\"" >/dev/null 2>&1 || true
}

progress "Switching theme..."

staging="$STATE_ROOT/.theme.switching.$$"
previous="$STATE_ROOT/.theme.previous.$$"
cleanup_switch() { /bin/rm -rf "$staging" "$previous"; }
trap cleanup_switch EXIT
/bin/rm -rf "$staging" "$previous"
/bin/mkdir -p "$staging"
/usr/bin/rsync -a --delete "$SRC/" "$staging/"
/bin/chmod 700 "$staging"
/bin/chmod 600 "$staging/"* 2>/dev/null || true

THEME_NAME="$(/usr/bin/python3 - "$staging/theme.json" "$THEME_ID" <<'PY'
import json, os, sys
with open(sys.argv[1], encoding="utf-8") as f:
    theme = json.load(f)
image = theme.get("image")
if theme.get("schemaVersion") != 1 or not isinstance(image, str) or os.path.basename(image) != image:
    raise SystemExit(1)
if not os.path.isfile(os.path.join(os.path.dirname(sys.argv[1]), image)):
    raise SystemExit(1)
print(theme.get("name") or sys.argv[2], end="")
PY
)" || fail "Theme package is invalid: $THEME_ID"

if [ -e "$THEME_DIR" ]; then /bin/mv "$THEME_DIR" "$previous"; fi
if ! /bin/mv "$staging" "$THEME_DIR"; then
  [ -e "$previous" ] && /bin/mv "$previous" "$THEME_DIR"
  fail "Could not activate theme package: $THEME_ID"
fi
/bin/rm -rf "$previous"
trap - EXIT

if [ "$APPLY_NOW" != "true" ]; then
  progress "Ready: ${THEME_NAME} (not applied)"
  printf 'result=ready\ntheme=%s\n' "$THEME_NAME"
  exit 0
fi

PORT=9341
if [ -f "$STATE_PATH" ]; then
  saved="$(/usr/bin/python3 - "$STATE_PATH" <<'PY' 2>/dev/null || true
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as f:
        value = json.load(f).get("port")
    if isinstance(value, int) and 1024 <= value <= 65535:
        print(value, end="")
except Exception:
    pass
PY
)"
  [ -n "$saved" ] && PORT="$saved"
fi

if hot_reapply_theme "$PORT" 8000; then
  progress "Done: ${THEME_NAME}"
  printf 'result=applied\ntheme=%s\n' "$THEME_NAME"
  exit 0
fi

if [ "$HOT_ONLY" = "true" ]; then
  progress "Selected: ${THEME_NAME}; it will apply when the skin reconnects."
  printf 'result=queued\ntheme=%s\n' "$THEME_NAME"
  exit 0
fi

progress "CDP not ready, full start..."
if "$SCRIPT_DIR/start-dream-skin-macos.sh" --port "$PORT" --restart-existing; then
  progress "Done: ${THEME_NAME}"
  printf 'result=applied\ntheme=%s\n' "$THEME_NAME"
  exit 0
fi

/usr/bin/osascript -e 'display alert "Codex Dream Skin" message "Theme switched but inject failed. Click Apply Skin."' >/dev/null 2>&1 || true
exit 1
