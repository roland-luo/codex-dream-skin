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
APPLY_NOW="true"
RESET_DEMO="false"
PORT=9341

while [ "$#" -gt 0 ]; do
  case "$1" in
    --image) IMAGE="${2:-}"; shift 2 ;;
    --name) THEME_NAME="${2:-}"; shift 2 ;;
    --tagline) TAGLINE="${2:-}"; shift 2 ;;
    --quote) QUOTE="${2:-}"; shift 2 ;;
    --accent) ACCENT="${2:-}"; shift 2 ;;
    --secondary) SECONDARY="${2:-}"; shift 2 ;;
    --highlight) HIGHLIGHT="${2:-}"; shift 2 ;;
    --preset) PRESET="${2:-}"; shift 2 ;;
    --art-position) ART_POSITION="${2:-}"; shift 2 ;;
    --port) PORT="${2:-}"; shift 2 ;;
    --no-apply) APPLY_NOW="false"; shift ;;
    --reset-demo) RESET_DEMO="true"; shift ;;
    *) fail "Unknown customize argument: $1" ;;
  esac
done

case "$PORT" in ''|*[!0-9]*) fail "Invalid port: $PORT" ;; esac
[ "$PORT" -ge 1024 ] && [ "$PORT" -le 65535 ] || fail "Port must be between 1024 and 65535."
case "$PRESET" in ''|rose|portal|adaptive) ;; *) fail "Preset must be rose, portal, or adaptive." ;; esac

discover_codex_app
require_macos_runtime
ensure_state_root

if [ "$RESET_DEMO" = "true" ]; then
  "$NODE" "$SCRIPT_DIR/write-theme.mjs" reset-demo --output-dir "$THEME_DIR"
else
  if [ -z "$IMAGE" ]; then
    IMAGE="$(/usr/bin/osascript -e 'POSIX path of (choose file with prompt "选择一张主题图片（建议横向、宽度 2000px 以上）" of type {"public.image"})')" \
      || fail "Image selection was cancelled."
  fi
  [ -f "$IMAGE" ] || fail "Selected image does not exist: $IMAGE"
  SOURCE_BYTES="$(/usr/bin/stat -f '%z' "$IMAGE")"
  [ "$SOURCE_BYTES" -le 52428800 ] || fail "Selected image is larger than 50 MB. Choose a smaller file."

  if [ -z "$THEME_NAME" ]; then
    THEME_NAME="$(/usr/bin/osascript -e 'text returned of (display dialog "给这套主题起个名字" default answer "我的 Codex Dream Skin" buttons {"取消", "继续"} default button "继续")')" \
      || fail "Theme setup was cancelled."
  fi
  if [ -z "$TAGLINE" ]; then TAGLINE="把喜欢的画面变成可交互的 Codex 工作台。"; fi
  if [ -z "$QUOTE" ]; then QUOTE="MAKE SOMETHING WONDERFUL"; fi

  /bin/mkdir -p "$THEME_DIR"
  /bin/chmod 700 "$THEME_DIR"
  image_name="background-$(/bin/date '+%Y%m%d-%H%M%S')-$$.jpg"
  temporary="$THEME_DIR/.${image_name}.tmp.jpg"
  palette_bitmap="$THEME_DIR/.${image_name}.palette.bmp"
  prepared="$THEME_DIR/$image_name"
  cleanup_temporary() { /bin/rm -f "$temporary" "$palette_bitmap"; }
  trap cleanup_temporary EXIT
  /usr/bin/sips -s format jpeg -s formatOptions 84 -Z 3200 "$IMAGE" --out "$temporary" >/dev/null \
    || fail "macOS could not convert the selected image. Use PNG, JPEG, HEIC, TIFF, or WebP."
  [ -s "$temporary" ] || fail "The converted image is empty."
  PREPARED_BYTES="$(/usr/bin/stat -f '%z' "$temporary")"
  [ "$PREPARED_BYTES" -le 16777216 ] || fail "The prepared image is larger than 16 MB. Choose a simpler or smaller image."
  /bin/mv -f "$temporary" "$prepared"
  /bin/chmod 600 "$prepared"

  /usr/bin/sips -Z 48 -s format bmp "$prepared" --out "$palette_bitmap" >/dev/null \
    || fail "macOS could not prepare the image palette sample."
  PALETTE_JSON="$("$NODE" "$SCRIPT_DIR/analyze-image.mjs" "$palette_bitmap")" \
    || fail "Could not analyze the image palette."
  SOURCE_ASPECT_RATIO="$("$NODE" -e 'const p=JSON.parse(process.argv[1]);process.stdout.write(String(p.aspectRatio||1))' "$PALETTE_JSON")"
  if "$NODE" -e 'process.exit(Number(process.argv[1]) < 1.4 ? 0 : 1)' "$SOURCE_ASPECT_RATIO"; then
    printf 'Codex Dream Skin Studio: square/portrait image detected; enabling stronger task-page quieting.\n' >&2
  fi

  write_args=(custom
    --output-dir "$THEME_DIR" --image "$image_name"
    --name "$THEME_NAME" --tagline "$TAGLINE" --quote "$QUOTE"
    --palette-json "$PALETTE_JSON" --source-aspect-ratio "$SOURCE_ASPECT_RATIO")
  [ -z "$ACCENT" ] || write_args+=(--accent "$ACCENT")
  [ -z "$SECONDARY" ] || write_args+=(--secondary "$SECONDARY")
  [ -z "$HIGHLIGHT" ] || write_args+=(--highlight "$HIGHLIGHT")
  [ -z "$PRESET" ] || write_args+=(--preset "$PRESET")
  [ -z "$ART_POSITION" ] || write_args+=(--art-position "$ART_POSITION")
  "$NODE" "$SCRIPT_DIR/write-theme.mjs" "${write_args[@]}"
  /usr/bin/find "$THEME_DIR" -maxdepth 1 -type f -name 'background-*' ! -name "$image_name" -delete
  trap - EXIT
fi

if [ "$APPLY_NOW" = "true" ]; then
  "$SCRIPT_DIR/start-dream-skin-macos.sh" --port "$PORT" --prompt-restart
fi

printf 'Codex Dream Skin Studio theme is ready.\n'
