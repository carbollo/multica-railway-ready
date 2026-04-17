#!/bin/sh
set -e

if [ -z "${MULTICA_SERVER_URL:-}" ]; then
  echo "MULTICA_SERVER_URL is required (HTTPS base of your Multica app, e.g. https://xxx.up.railway.app)" >&2
  exit 1
fi

if [ -z "${MULTICA_TOKEN:-}" ] && [ -z "${MULTICA_CLI_TOKEN:-}" ]; then
  echo "MULTICA_TOKEN is required: create a Personal Access Token (mul_...) in the web app and paste it here." >&2
  exit 1
fi

export MULTICA_TOKEN="${MULTICA_TOKEN:-$MULTICA_CLI_TOKEN}"
export HOME="${HOME:-/var/lib/multica}"
mkdir -p "$HOME"

exec multica daemon start --foreground --server-url "$MULTICA_SERVER_URL" \
  ${MULTICA_DAEMON_DEVICE_NAME:+--device-name "$MULTICA_DAEMON_DEVICE_NAME"} \
  ${MULTICA_AGENT_RUNTIME_NAME:+--runtime-name "$MULTICA_AGENT_RUNTIME_NAME"}
