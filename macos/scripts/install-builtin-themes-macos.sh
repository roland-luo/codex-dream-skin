#!/bin/bash

# Install or refresh only the five reserved built-in theme packs. User-created
# theme directories are never removed or rewritten.

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

QUIET="false"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --quiet) QUIET="true"; shift ;;
    *) fail "Unknown built-in theme installer argument: $1" ;;
  esac
done

[ -f "$BUILTIN_THEMES_MANIFEST" ] || fail "Built-in theme manifest is missing."
ensure_state_root
/bin/mkdir -p "$THEMES_ROOT"
/bin/chmod 700 "$THEMES_ROOT"

theme_ids="$({ /usr/bin/python3 - "$BUILTIN_THEMES_MANIFEST" <<'PY'
import json, re, sys
with open(sys.argv[1], encoding="utf-8") as f:
    manifest = json.load(f)
themes = manifest.get("themes")
if manifest.get("schemaVersion") != 1 or not isinstance(themes, list) or len(themes) != 5:
    raise SystemExit("manifest must contain exactly five themes")
seen = set()
for theme_id in themes:
    if not isinstance(theme_id, str) or not re.fullmatch(r"[a-z0-9-]{1,80}", theme_id):
        raise SystemExit("invalid built-in theme id")
    if theme_id in seen:
        raise SystemExit("duplicate built-in theme id")
    seen.add(theme_id)
    print(theme_id)
PY
  } 2>/dev/null)" || fail "Built-in theme manifest is invalid."
[ -n "$theme_ids" ] || fail "Built-in theme manifest is empty."

installed=0
while IFS= read -r theme_id; do
  [ -n "$theme_id" ] || continue
  source_dir="$BUILTIN_THEMES_ROOT/$theme_id"
  theme_json="$source_dir/theme.json"
  [ -f "$theme_json" ] || fail "Built-in theme config is missing: $theme_id"
  image_name="$(/usr/bin/python3 - "$theme_json" "$theme_id" <<'PY'
import json, os, sys
with open(sys.argv[1], encoding="utf-8") as f:
    theme = json.load(f)
image = theme.get("image")
if theme.get("schemaVersion") != 1 or theme.get("id") != sys.argv[2]:
    raise SystemExit(1)
if not isinstance(image, str) or os.path.basename(image) != image:
    raise SystemExit(1)
print(image, end="")
PY
  )" || fail "Built-in theme config is invalid: $theme_id"
  [ -f "$source_dir/$image_name" ] || fail "Built-in theme image is missing: $theme_id/$image_name"

  destination="$THEMES_ROOT/$theme_id"
  staging="$THEMES_ROOT/.${theme_id}.installing.$$"
  previous="$THEMES_ROOT/.${theme_id}.previous.$$"
  /bin/rm -rf "$staging" "$previous"
  /bin/mkdir -p "$staging"
  /usr/bin/rsync -a --delete "$source_dir/" "$staging/"
  /bin/chmod 700 "$staging"
  /bin/chmod 600 "$staging/"* 2>/dev/null || true
  if [ -e "$destination" ]; then /bin/mv "$destination" "$previous"; fi
  if ! /bin/mv "$staging" "$destination"; then
    [ -e "$previous" ] && /bin/mv "$previous" "$destination"
    fail "Could not install built-in theme: $theme_id"
  fi
  /bin/rm -rf "$previous"
  installed=$((installed + 1))
done <<EOF
$theme_ids
EOF

[ "$installed" -eq 5 ] || fail "Expected five built-in themes; installed $installed."
if [ "$QUIET" != "true" ]; then
  printf 'Installed %s built-in Codex Dream Skin themes.\n' "$installed"
fi
