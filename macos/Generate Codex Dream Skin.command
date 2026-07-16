#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd -P)"
exec "$ROOT/scripts/generate-dream-skin-macos.sh"
