#!/bin/bash

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

IMAGE=""
THEME_NAME=""
TAGLINE=""
QUOTE=""
ACCENT=""
SECONDARY=""
HIGHLIGHT=""
PRESET=""
ART_POSITION=""
PORT=9341
PORT_EXPLICIT="false"
RESET_DEMO="false"
APPLY_NOW="true"
VERIFY_NOW="true"
SCREENSHOT=""

usage() {
  /usr/bin/printf '%s\n' \
    'Generate and apply one Codex Dream Skin in a single command.' \
    '' \
    'Usage:' \
    '  generate-dream-skin-macos.sh [options]' \
    '' \
    'Options:' \
    '  --image <path>       Source PNG/JPEG/HEIC/TIFF/WebP; Finder opens when omitted' \
    '  --name <text>        Theme name; a dialog opens when omitted' \
    '  --tagline <text>     Optional home tagline' \
    '  --quote <text>       Optional decorative quote' \
    '  --accent <#rrggbb>   Primary accent color' \
    '  --secondary <#rrggbb> Secondary accent color' \
    '  --highlight <#rrggbb> Highlight color' \
    '  --preset <name>      Design profile: rose, portal, or adaptive' \
    '  --art-position <pos> Artwork focus, for example "58% center"' \
    '  --port <number>      Preferred loopback CDP port (default: 9341)' \
    '  --screenshot <path>  Save a verification screenshot' \
    '  --reset-demo         Restore the bundled demo theme' \
    '  --no-apply           Generate theme files without applying them' \
    '  --no-verify          Apply without the final strict verification' \
    '  -h, --help           Show this help'
}

need_value() {
  [ "$#" -ge 2 ] && [ -n "${2:-}" ] || fail "Missing value for $1"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --image) need_value "$@"; IMAGE="$2"; shift 2 ;;
    --name) need_value "$@"; THEME_NAME="$2"; shift 2 ;;
    --tagline) need_value "$@"; TAGLINE="$2"; shift 2 ;;
    --quote) need_value "$@"; QUOTE="$2"; shift 2 ;;
    --accent) need_value "$@"; ACCENT="$2"; shift 2 ;;
    --secondary) need_value "$@"; SECONDARY="$2"; shift 2 ;;
    --highlight) need_value "$@"; HIGHLIGHT="$2"; shift 2 ;;
    --preset) need_value "$@"; PRESET="$2"; shift 2 ;;
    --art-position) need_value "$@"; ART_POSITION="$2"; shift 2 ;;
    --port) need_value "$@"; PORT="$2"; PORT_EXPLICIT="true"; shift 2 ;;
    --screenshot) need_value "$@"; SCREENSHOT="$2"; shift 2 ;;
    --reset-demo) RESET_DEMO="true"; shift ;;
    --no-apply) APPLY_NOW="false"; shift ;;
    --no-verify) VERIFY_NOW="false"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown generate argument: $1" ;;
  esac
done

if [ "$PORT_EXPLICIT" = "false" ] && [ -f "$STATE_PATH" ]; then
  saved_port="$(/usr/bin/plutil -extract port raw -o - "$STATE_PATH" 2>/dev/null || true)"
  [ -z "$saved_port" ] || PORT="$saved_port"
fi

case "$PORT" in ''|*[!0-9]*) fail "Invalid port: $PORT" ;; esac
[ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ] || fail "Port must be between 1024 and 65535."
case "$PRESET" in ''|rose|portal|adaptive) ;; *) fail "Preset must be rose, portal, or adaptive." ;; esac
[ -z "$SCREENSHOT" ] || [ "$APPLY_NOW" = "true" ] || fail "--screenshot requires applying the theme."

# When invoked from a checked-out or downloaded Skill, install/update the stable
# engine first. When invoked from the installed engine, avoid copying over itself.
ENGINE_ROOT="$PROJECT_ROOT"
if [ "$PROJECT_ROOT" != "$INSTALL_ROOT" ]; then
  "$SCRIPT_DIR/install-dream-skin-macos.sh" --port "$PORT" --no-launch
  ENGINE_ROOT="$INSTALL_ROOT"
fi

CUSTOMIZE="$ENGINE_ROOT/scripts/customize-theme-macos.sh"
VERIFY="$ENGINE_ROOT/scripts/verify-dream-skin-macos.sh"
[ -x "$CUSTOMIZE" ] || fail "Customize engine is missing: $CUSTOMIZE"
[ -x "$VERIFY" ] || fail "Verification engine is missing: $VERIFY"

customize_args=(--port "$PORT")
if [ "$RESET_DEMO" = "true" ]; then
  customize_args+=(--reset-demo)
else
  [ -z "$IMAGE" ] || customize_args+=(--image "$IMAGE")
  [ -z "$THEME_NAME" ] || customize_args+=(--name "$THEME_NAME")
  [ -z "$TAGLINE" ] || customize_args+=(--tagline "$TAGLINE")
  [ -z "$QUOTE" ] || customize_args+=(--quote "$QUOTE")
  [ -z "$ACCENT" ] || customize_args+=(--accent "$ACCENT")
  [ -z "$SECONDARY" ] || customize_args+=(--secondary "$SECONDARY")
  [ -z "$HIGHLIGHT" ] || customize_args+=(--highlight "$HIGHLIGHT")
  [ -z "$PRESET" ] || customize_args+=(--preset "$PRESET")
  [ -z "$ART_POSITION" ] || customize_args+=(--art-position "$ART_POSITION")
fi
[ "$APPLY_NOW" = "true" ] || customize_args+=(--no-apply)

"$CUSTOMIZE" "${customize_args[@]}"

if [ "$APPLY_NOW" != "true" ]; then
  printf 'One-click generation completed without applying; verification was skipped.\n'
  exit 0
fi

if [ "$VERIFY_NOW" = "true" ]; then
  quality_screenshot="${SCREENSHOT:-$STATE_ROOT/last-verification.png}"
  quality_bitmap="$STATE_ROOT/.last-verification.bmp"
  verify_args=(--screenshot "$quality_screenshot")
  VERIFY_JSON="$("$VERIFY" "${verify_args[@]}")"
  printf '%s\n' "$VERIFY_JSON"
  ensure_node_runtime
  HOME_ROUTE="$("$NODE" -e '
    const value=JSON.parse(process.argv[1]);
    process.stdout.write(value.targets?.some((target)=>target.result?.homeRoute) ? "true" : "false");
  ' "$VERIFY_JSON")"
  if [ "$HOME_ROUTE" != "true" ]; then
    /usr/bin/sips -Z 360 -s format bmp "$quality_screenshot" --out "$quality_bitmap" >/dev/null \
      || fail "Could not prepare the task-page visual quality sample."
    if ! "$NODE" "$ENGINE_ROOT/scripts/check-visual-quality.mjs" "$quality_bitmap"; then
      /bin/rm -f "$quality_bitmap"
      fail "Task-page artwork is too visually dominant; generation was applied but did not pass visual quality verification."
    fi
    /bin/rm -f "$quality_bitmap"
  fi
  printf 'One-click generation, apply, and verification completed.\n'
else
  printf 'One-click generation and apply completed; final verification was skipped.\n'
fi
