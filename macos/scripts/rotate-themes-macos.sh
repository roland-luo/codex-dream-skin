#!/bin/bash

# User-level 30-minute theme rotation. Scheduled ticks only hot-apply through an
# already-verified loopback CDP session; they never restart Codex.

set -euo pipefail
. "$(cd "$(dirname "$0")" && pwd -P)/common-macos.sh"

MODE="status"
QUIET="false"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --enable|--disable|--toggle|--next|--tick|--status) MODE="${1#--}"; shift ;;
    --quiet) QUIET="true"; shift ;;
    *) fail "Unknown theme rotation argument: $1" ;;
  esac
done

ROTATION_INTERVAL_SECONDS="$(/usr/bin/python3 - "$BUILTIN_THEMES_MANIFEST" <<'PY' 2>/dev/null || true
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as f:
        value = int(json.load(f).get("rotationIntervalSeconds", 1800))
    print(value if value >= 300 else 1800, end="")
except Exception:
    pass
PY
)"
[ -n "$ROTATION_INTERVAL_SECONDS" ] || ROTATION_INTERVAL_SECONDS=1800

notify() {
  [ "$QUIET" = "true" ] && return 0
  /usr/bin/osascript -e "display notification \"$1\" with title \"Codex Dream Skin\"" >/dev/null 2>&1 || true
}

read_json_field() {
  /usr/bin/python3 - "$1" "$2" 2>/dev/null <<'PY' || true
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as f:
        value = json.load(f).get(sys.argv[2])
    if value is True:
        print("true", end="")
    elif value is False:
        print("false", end="")
    elif value is not None:
        print(value, end="")
except Exception:
    pass
PY
}

manifest_theme_ids() {
  /usr/bin/python3 - "$BUILTIN_THEMES_MANIFEST" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    for theme_id in json.load(f)["themes"]:
        print(theme_id)
PY
}

active_theme_id() {
  read_json_field "$THEME_DIR/theme.json" id
}

theme_name() {
  local theme_id="$1"
  local name
  name="$(read_json_field "$THEMES_ROOT/$theme_id/theme.json" name)"
  printf '%s' "${name:-$theme_id}"
}

next_theme_id() {
  local current="$1"
  local first=""
  local emit_next="false"
  local found="false"
  local theme_id
  while IFS= read -r theme_id; do
    [ -n "$first" ] || first="$theme_id"
    if [ "$emit_next" = "true" ]; then
      printf '%s' "$theme_id"
      return 0
    fi
    if [ "$theme_id" = "$current" ]; then
      found="true"
      emit_next="true"
    fi
  done <<EOF
$(manifest_theme_ids)
EOF
  [ "$found" = "true" ] || :
  printf '%s' "$first"
}

write_rotation_state() {
  local enabled="$1"
  local current_id="$2"
  local result="$3"
  local record_run="$4"
  ensure_state_root
  /usr/bin/python3 - "$ROTATION_STATE_PATH" "$enabled" "$ROTATION_INTERVAL_SECONDS" "$current_id" "$result" "$record_run" <<'PY'
import datetime, json, os, sys
path, enabled, interval, current, result, record_run = sys.argv[1:]
try:
    with open(path, encoding="utf-8") as f:
        state = json.load(f)
except Exception:
    state = {}
now = datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00", "Z")
state.update({
    "schemaVersion": 1,
    "enabled": enabled == "true",
    "intervalSeconds": int(interval),
    "currentThemeId": current,
    "updatedAt": now,
})
if result:
    state["lastResult"] = result
if record_run == "true":
    state["lastRunAt"] = now
temporary = f"{path}.{os.getpid()}.tmp"
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(temporary, "w", encoding="utf-8") as f:
    json.dump(state, f, ensure_ascii=False, indent=2)
    f.write("\n")
os.chmod(temporary, 0o600)
os.replace(temporary, path)
PY
}

rotation_enabled() {
  [ "$(read_json_field "$ROTATION_STATE_PATH" enabled)" = "true" ] && [ -f "$ROTATION_PLIST_PATH" ]
}

install_builtins_if_needed() {
  local count=0
  local theme_id
  while IFS= read -r theme_id; do
    [ -f "$THEMES_ROOT/$theme_id/theme.json" ] && count=$((count + 1))
  done <<EOF
$(manifest_theme_ids)
EOF
  if [ "$count" -ne 5 ]; then
    "$SCRIPT_DIR/install-builtin-themes-macos.sh" --quiet
  fi
}

enable_rotation() {
  "$SCRIPT_DIR/install-builtin-themes-macos.sh" --quiet
  ensure_state_root
  /bin/mkdir -p "$ROTATION_LAUNCH_AGENTS_DIR"
  /usr/bin/python3 - "$ROTATION_PLIST_PATH" "$ROTATION_LABEL" "$SCRIPT_DIR/rotate-themes-macos.sh" \
    "$ROTATION_INTERVAL_SECONDS" "$ROTATION_LOG" "$ROTATION_ERROR_LOG" "$HOME" <<'PY'
import os, plistlib, sys
path, label, script, interval, stdout, stderr, home = sys.argv[1:]
payload = {
    "Label": label,
    "ProgramArguments": ["/bin/bash", script, "--tick", "--quiet"],
    "StartInterval": int(interval),
    "RunAtLoad": False,
    "ProcessType": "Background",
    "EnvironmentVariables": {"HOME": home},
    "StandardOutPath": stdout,
    "StandardErrorPath": stderr,
}
temporary = f"{path}.{os.getpid()}.tmp"
with open(temporary, "wb") as f:
    plistlib.dump(payload, f, fmt=plistlib.FMT_XML, sort_keys=True)
os.chmod(temporary, 0o600)
os.replace(temporary, path)
PY
  if [ "${CODEX_DREAM_SKIN_SKIP_LAUNCHCTL:-false}" != "true" ]; then
    domain="gui/$(/usr/bin/id -u)"
    /bin/launchctl bootout "$domain/$ROTATION_LABEL" >/dev/null 2>&1 || true
    if ! /bin/launchctl bootstrap "$domain" "$ROTATION_PLIST_PATH" >/dev/null 2>&1; then
      /bin/rm -f "$ROTATION_PLIST_PATH"
      write_rotation_state "false" "$(active_theme_id)" "launchctl-error" "false"
      fail "Could not enable the 30-minute theme rotation LaunchAgent."
    fi
  fi
  write_rotation_state "true" "$(active_theme_id)" "enabled" "false"
  notify "已开启：每 30 分钟自动切换主题"
  printf 'Theme rotation enabled: every %s minutes.\n' "$((ROTATION_INTERVAL_SECONDS / 60))"
}

disable_rotation() {
  if [ "${CODEX_DREAM_SKIN_SKIP_LAUNCHCTL:-false}" != "true" ]; then
    /bin/launchctl bootout "gui/$(/usr/bin/id -u)/$ROTATION_LABEL" >/dev/null 2>&1 || true
  fi
  /bin/rm -f "$ROTATION_PLIST_PATH"
  write_rotation_state "false" "$(active_theme_id)" "disabled" "false"
  notify "已关闭自动主题轮换"
  printf 'Theme rotation disabled.\n'
}

perform_rotation() {
  local source="$1"
  local current_id next_id next_name switch_output result enabled_state="false"
  install_builtins_if_needed
  current_id="$(active_theme_id)"
  [ -n "$current_id" ] || current_id="$(read_json_field "$ROTATION_STATE_PATH" currentThemeId)"
  next_id="$(next_theme_id "$current_id")"
  [ -n "$next_id" ] || fail "No built-in theme is available for rotation."
  switch_output="$("$SCRIPT_DIR/switch-theme-macos.sh" --id "$next_id" --hot-only --quiet)"
  result="$(printf '%s\n' "$switch_output" | /usr/bin/awk -F= '/^result=/{print $2; exit}')"
  [ -n "$result" ] || result="queued"
  rotation_enabled && enabled_state="true"
  write_rotation_state "$enabled_state" "$next_id" "$result" "true"
  next_name="$(theme_name "$next_id")"
  if [ "$source" = "manual" ]; then
    if [ "$result" = "applied" ]; then
      notify "已切换：$next_name"
    else
      notify "已选中：${next_name}；下次应用皮肤时生效"
    fi
  fi
  printf 'theme=%s\nresult=%s\n' "$next_name" "$result"
}

show_status() {
  local enabled="false" current_id next_id current_name next_name last_result
  rotation_enabled && enabled="true"
  current_id="$(active_theme_id)"
  [ -n "$current_id" ] || current_id="$(read_json_field "$ROTATION_STATE_PATH" currentThemeId)"
  next_id="$(next_theme_id "$current_id")"
  current_name="$(theme_name "$current_id")"
  next_name="$(theme_name "$next_id")"
  last_result="$(read_json_field "$ROTATION_STATE_PATH" lastResult)"
  printf 'enabled=%s\n' "$enabled"
  printf 'intervalSeconds=%s\n' "$ROTATION_INTERVAL_SECONDS"
  printf 'currentThemeId=%s\ncurrentTheme=%s\n' "$current_id" "$current_name"
  printf 'nextThemeId=%s\nnextTheme=%s\n' "$next_id" "$next_name"
  printf 'lastResult=%s\n' "$last_result"
}

case "$MODE" in
  enable) enable_rotation ;;
  disable) disable_rotation ;;
  toggle)
    if rotation_enabled; then disable_rotation; else enable_rotation; fi
    ;;
  next) perform_rotation manual ;;
  tick)
    rotation_enabled || exit 0
    ensure_state_root
    lock_dir="$STATE_ROOT/rotation.lock"
    /bin/mkdir "$lock_dir" 2>/dev/null || exit 0
    trap '/bin/rmdir "$lock_dir" 2>/dev/null || true' EXIT
    perform_rotation scheduled
    ;;
  status) show_status ;;
esac
