#!/bin/bash

# Install a per-user terminal command without requiring sudo.

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

BIN_DIR="${CODEX_DREAM_SKIN_BIN_DIR:-$HOME/.local/bin}"
COMMAND_NAME="codex-dream-skin"
CLI_SCRIPT="$SCRIPT_DIR/theme-cli-macos.sh"
[ -x "$CLI_SCRIPT" ] || fail "Theme CLI script is missing: $CLI_SCRIPT"

/bin/mkdir -p "$BIN_DIR"
/bin/chmod 700 "$BIN_DIR" 2>/dev/null || true
target="$BIN_DIR/$COMMAND_NAME"
if [ -e "$target" ] && ! /usr/bin/grep -q '^# CodexDreamSkinStudio CLI launcher$' "$target" 2>/dev/null; then
  COMMAND_NAME="codex-dream-skin-studio"
  target="$BIN_DIR/$COMMAND_NAME"
  if [ -e "$target" ] && ! /usr/bin/grep -q '^# CodexDreamSkinStudio CLI launcher$' "$target" 2>/dev/null; then
    fail "Both Codex Dream Skin command names are already used by unrelated files in $BIN_DIR."
  fi
fi

{
  printf '%s\n' '#!/bin/bash'
  printf '%s\n' '# CodexDreamSkinStudio CLI launcher'
  printf 'exec %q "$@"\n' "$CLI_SCRIPT"
} > "$target"
/bin/chmod 755 "$target"

printf 'Installed terminal command: %s\n' "$target"
case ":${PATH:-}:" in
  *":$BIN_DIR:"*) ;;
  *) printf 'Add %s to PATH to run %s without its full path.\n' "$BIN_DIR" "$COMMAND_NAME" ;;
esac
