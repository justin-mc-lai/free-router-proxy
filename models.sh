#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -eq 0 ]; then
  owner="$(stat -c '%U' "$DIR")"
  if [ -n "$owner" ] && [ "$owner" != "root" ] && command -v runuser >/dev/null 2>&1; then
    exec runuser -u "$owner" -- "$DIR/models.sh" "$@"
  fi
fi

load_env() {
  local file="$1"
  [ -f "$file" ] || return 0
  set -a
  set +e +u
  # shellcheck disable=SC1090
  source "$file" >/dev/null 2>&1 || true
  set -e -u
  set +a
  return 0
}

load_env "${HOME}/.hermes/.env"
load_env "$DIR/.env"

exec node "$DIR/list-models.mjs" "$@"
