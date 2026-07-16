#!/bin/bash

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
NODE="${NODE:-/Applications/ChatGPT.app/Contents/Resources/cua_node/bin/node}"
[ -x "$NODE" ] || { printf 'Codex bundled Node.js was not found: %s\n' "$NODE" >&2; exit 1; }

while IFS= read -r file; do /bin/bash -n "$file"; done < <(
  /usr/bin/find "$ROOT" -type f \( -name '*.sh' -o -name '*.command' \) \
    ! -path '*/release/*' -print
)
while IFS= read -r file; do "$NODE" --check "$file" >/dev/null; done < <(
  /usr/bin/find "$ROOT/scripts" "$ROOT/assets" -type f \( -name '*.mjs' -o -name '*.js' \) -print
)

if /usr/bin/grep -R -n -E 'dream-skin-skin|DREAM_SKIN_SKIN|1\.0\.0-rc2' \
  "$ROOT/scripts" "$ROOT/assets" >/dev/null; then
  printf 'Legacy release-candidate identifiers remain in runtime files.\n' >&2
  exit 1
fi
if /usr/bin/grep -R -n -E '(writeFile|rename|copyFile|rm).*app\.asar' "$ROOT/scripts" >/dev/null; then
  printf 'A runtime script appears to mutate app.asar.\n' >&2
  exit 1
fi

DEFAULT_PAYLOAD_JSON="$("$NODE" "$ROOT/scripts/injector.mjs" --check-payload)"
"$NODE" -e '
  const value = JSON.parse(process.argv[1]);
  if (!value.pass || value.version !== "1.4.0" || value.themePreset !== "rose" ||
      value.themeName !== "桥本有菜专属定制皮肤" || value.imageBytes < 1) process.exit(1);
' "$DEFAULT_PAYLOAD_JSON"

TMP="$(/usr/bin/mktemp -d /tmp/codex-dream-skin-tests.XXXXXX)"
trap '/bin/rm -rf "$TMP"' EXIT
/bin/mkdir -p "$TMP/theme"
if HOME="$TMP" "$ROOT/scripts/generate-dream-skin-macos.sh" --port 1 >/dev/null 2>&1; then
  printf 'One-click generator accepted an unsafe CDP port.\n' >&2
  exit 1
fi
if HOME="$TMP" "$ROOT/scripts/generate-dream-skin-macos.sh" \
  --no-apply --screenshot "$TMP/invalid.png" >/dev/null 2>&1; then
  printf 'One-click generator accepted a screenshot without applying.\n' >&2
  exit 1
fi
if HOME="$TMP" "$ROOT/scripts/generate-dream-skin-macos.sh" \
  --no-apply --preset generic >/dev/null 2>&1; then
  printf 'One-click generator accepted an unknown design profile.\n' >&2
  exit 1
fi
/bin/cp "$ROOT/assets/portal-hero.png" "$TMP/theme/background.png"

WARM_BMP="$TMP/warm-red.bmp"
QUIET_BMP="$TMP/quiet-neutral.bmp"
WIDE_ROSE_BMP="$TMP/wide-rose.bmp"
DARK_PORTAL_BMP="$TMP/dark-portal.bmp"
"$NODE" -e '
  const fs = require("fs");
  function writeBmp(file, [r, g, b], width = 4, height = 4) {
    const row = Math.floor((24 * width + 31) / 32) * 4, offset = 54;
    const out = Buffer.alloc(offset + row * height);
    out.write("BM", 0, "ascii");
    out.writeUInt32LE(out.length, 2); out.writeUInt32LE(offset, 10);
    out.writeUInt32LE(40, 14); out.writeInt32LE(width, 18); out.writeInt32LE(-height, 22);
    out.writeUInt16LE(1, 26); out.writeUInt16LE(24, 28);
    out.writeUInt32LE(row * height, 34);
    for (let i = offset; i < out.length; i += 3) {
      out[i] = b; out[i + 1] = g; out[i + 2] = r;
    }
    fs.writeFileSync(file, out);
  }
  writeBmp(process.argv[1], [0xed, 0x3d, 0x16]);
  writeBmp(process.argv[2], [0xf5, 0xf1, 0xef]);
  writeBmp(process.argv[3], [0xf0, 0xc2, 0xc8], 8, 4);
  writeBmp(process.argv[4], [0x15, 0x24, 0x37], 8, 4);
' "$WARM_BMP" "$QUIET_BMP" "$WIDE_ROSE_BMP" "$DARK_PORTAL_BMP"
PALETTE_JSON="$("$NODE" "$ROOT/scripts/analyze-image.mjs" "$WARM_BMP")"
"$NODE" -e '
  const value = JSON.parse(process.argv[1]);
  if (value.preset !== "adaptive" || value.temperature !== "warm" ||
      !/^#[0-9a-f]{6}$/i.test(value.accent) || value.accent.toLowerCase() === "#7cff46") process.exit(1);
' "$PALETTE_JSON"
ROSE_PALETTE_JSON="$("$NODE" "$ROOT/scripts/analyze-image.mjs" "$WIDE_ROSE_BMP")"
PORTAL_PALETTE_JSON="$("$NODE" "$ROOT/scripts/analyze-image.mjs" "$DARK_PORTAL_BMP")"
"$NODE" -e '
  const rose = JSON.parse(process.argv[1]);
  const portal = JSON.parse(process.argv[2]);
  if (rose.preset !== "rose" || portal.preset !== "portal") process.exit(1);
' "$ROSE_PALETTE_JSON" "$PORTAL_PALETTE_JSON"
if "$NODE" "$ROOT/scripts/check-visual-quality.mjs" "$WARM_BMP" >/dev/null 2>&1; then
  printf 'Visual quality gate accepted a high-saturation task surface.\n' >&2
  exit 1
fi
"$NODE" "$ROOT/scripts/check-visual-quality.mjs" "$QUIET_BMP" >/dev/null

"$NODE" "$ROOT/scripts/write-theme.mjs" custom --output-dir "$TMP/theme" \
  --image background.png --name '测试主题' --tagline '测试口号' --quote 'TEST' \
  --palette-json "$PALETTE_JSON" >/dev/null
PAYLOAD_JSON="$("$NODE" "$ROOT/scripts/injector.mjs" --check-payload --theme-dir "$TMP/theme")"
"$NODE" -e '
  const value = JSON.parse(process.argv[1]);
  if (!value.pass || value.version !== "1.4.0" || value.themePreset !== "adaptive" ||
      value.themeName !== "测试主题" || value.imageBytes < 1) process.exit(1);
' "$PAYLOAD_JSON"
"$NODE" "$ROOT/scripts/write-theme.mjs" reset-demo --output-dir "$TMP/theme" >/dev/null
[ ! -e "$TMP/theme" ]

CONFIG="$TMP/config.toml"
BACKUP="$TMP/theme-backup.json"
/usr/bin/printf '%s\n' \
  'model = "gpt-5"' \
  '' \
  '[desktop]' \
  'appearanceTheme = "system"' \
  'appearanceDarkCodeThemeId = "vscode-dark"' \
  'keepMe = true' > "$CONFIG"
/bin/cp "$CONFIG" "$TMP/original.toml"
"$NODE" "$ROOT/scripts/theme-config.mjs" install "$CONFIG" "$BACKUP" >/dev/null
/usr/bin/cmp -s "$CONFIG" "$TMP/original.toml"
[ -f "$BACKUP" ]
"$NODE" "$ROOT/scripts/theme-config.mjs" restore "$CONFIG" "$BACKUP" >/dev/null
/usr/bin/cmp -s "$CONFIG" "$TMP/original.toml"

GENERATOR_HELP="$("$ROOT/scripts/generate-dream-skin-macos.sh" --help)"
case "$GENERATOR_HELP" in
  *'Generate and apply one Codex Dream Skin in a single command.'*'--preset <name>'*'--art-position <pos>'*) ;;
  *) printf 'One-click generator help output is incomplete.\n' >&2; exit 1 ;;
esac

RECOVERABLE_HOME="$(/usr/bin/dscl . -read "/Users/$(/usr/bin/id -un)" NFSHomeDirectory 2>/dev/null | /usr/bin/awk '{print $2}' || true)"
if [ -n "$RECOVERABLE_HOME" ]; then
  /usr/bin/env -u HOME /bin/bash -c '. "$1/scripts/common-macos.sh"; [ -n "$HOME" ] && [ "$SKIN_VERSION" = "1.4.0" ]' _ "$ROOT"
else
  /bin/bash -c '. "$1/scripts/common-macos.sh"; [ -n "$HOME" ] && [ "$SKIN_VERSION" = "1.4.0" ]' _ "$ROOT"
fi
"$ROOT/scripts/doctor-macos.sh" >/dev/null

printf 'PASS: syntax, payload, custom-theme, config round-trip, HOME recovery, signature, and doctor checks.\n'
