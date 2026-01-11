#!/bin/sh
set -eu

echo "[entrypoint] uname=$(uname -a)" >&2
echo "[entrypoint] pwd=$(pwd)" >&2
echo "[entrypoint] listing:" >&2
ls -la >&2

# safer than printf "$CONFIG" (format-string issues)
: "${CONFIG:?CONFIG env var is not set}"
printf '%s' "$CONFIG" > config.toml

echo "[entrypoint] wrote config.toml bytes=$(wc -c < config.toml | tr -d " ")" >&2
echo "[entrypoint] config.toml head:" >&2
head -n 50 config.toml >&2 || true

if [ ! -e ./rathole ]; then
  echo "[entrypoint] ERROR: ./rathole does not exist" >&2
  exit 127
fi

if [ ! -x ./rathole ]; then
  echo "[entrypoint] ERROR: ./rathole exists but is not executable" >&2
  ls -la ./rathole >&2 || true
  exit 126
fi

exec ./rathole "$@"
