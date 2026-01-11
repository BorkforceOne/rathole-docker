#!/bin/sh
set -eu

: "${CONFIG:?CONFIG env var is not set}"

printf '%s' "$CONFIG" \
  | tr -d '\r' \
  | tr -d '\000-\010\013\014\016-\037' \
  > /app/config.toml

exec /app/rathole /app/config.toml "$@"
