#!/bin/bash

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
REPO_ROOT="$(cd "$ROOT/.." && pwd -P)"
VERSION="$(/usr/bin/tr -d '[:space:]' < "$ROOT/VERSION")"
RELEASE_DIR="$ROOT/release"
ARCHIVE="$RELEASE_DIR/codex-dream-skin-studio-v$VERSION.zip"
TMP="$(/usr/bin/mktemp -d /tmp/codex-dream-skin-release.XXXXXX)"
trap '/bin/rm -rf "$TMP"' EXIT

if [ "${1:-}" != "--skip-tests" ]; then "$ROOT/tests/run-tests.sh"; fi

/bin/mkdir -p "$TMP/codex-dream-skin-studio" "$RELEASE_DIR"
/usr/bin/rsync -a \
  --exclude '.git/' \
  --exclude '.DS_Store' \
  --exclude 'release/' \
  "$ROOT/" "$TMP/codex-dream-skin-studio/"
if [ -f "$REPO_ROOT/docs/images/gallery/skin.png" ] && \
   [ -f "$REPO_ROOT/docs/images/screenshot-macos-home.png" ] && \
   [ -f "$REPO_ROOT/docs/images/screenshot-macos-task.png" ]; then
  /bin/mkdir -p "$TMP/codex-dream-skin-studio/references/visual-targets"
  /bin/cp "$REPO_ROOT/docs/images/gallery/skin.png" \
    "$TMP/codex-dream-skin-studio/references/visual-targets/rose-home.png"
  /bin/cp "$REPO_ROOT/docs/images/screenshot-macos-home.png" \
    "$TMP/codex-dream-skin-studio/references/visual-targets/portal-home.png"
  /bin/cp "$REPO_ROOT/docs/images/screenshot-macos-task.png" \
    "$TMP/codex-dream-skin-studio/references/visual-targets/portal-task.png"
fi
/bin/chmod 755 "$TMP/codex-dream-skin-studio"/*.command
/bin/chmod 755 "$TMP/codex-dream-skin-studio"/scripts/*.sh "$TMP/codex-dream-skin-studio"/tests/*.sh
/usr/bin/xattr -cr "$TMP/codex-dream-skin-studio"
/usr/bin/find "$TMP/codex-dream-skin-studio" -type f \( -name '.DS_Store' -o -name '._*' \) -delete
/bin/rm -f "$ARCHIVE"
COPYFILE_DISABLE=1 /usr/bin/ditto -c -k --keepParent --norsrc --noextattr "$TMP/codex-dream-skin-studio" "$ARCHIVE"
SHA256="$(/usr/bin/shasum -a 256 "$ARCHIVE" | /usr/bin/awk '{print $1}')"
/usr/bin/printf '%s  %s\n' "$SHA256" "$(basename "$ARCHIVE")" > "$RELEASE_DIR/SHA256SUMS.txt"
/usr/bin/printf 'Created %s\nSHA-256 %s\n' "$ARCHIVE" "$SHA256"
