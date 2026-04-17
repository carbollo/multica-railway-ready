#!/bin/sh
set -e

# Railway sets $PORT for the HTTP listener the healthcheck hits (Next.js).
FRONTEND_PORT="${PORT:-3000}"
BACKEND_PORT="${BACKEND_PORT:-8080}"

echo "Running database migrations..."
export PORT="$BACKEND_PORT"
/app/migrate up

echo "Starting backend on ${BACKEND_PORT}..."
/app/server &
BACKEND_PID=$!

cleanup() {
  kill "$BACKEND_PID" 2>/dev/null || true
  wait "$BACKEND_PID" 2>/dev/null || true
}

export PORT="$FRONTEND_PORT"
export HOSTNAME="${HOSTNAME:-0.0.0.0}"

sleep 1
if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
  echo "Backend exited before frontend start" >&2
  exit 1
fi

echo "Starting frontend on ${PORT}..."
node /app/apps/web/server.js &
FRONTEND_PID=$!

trap 'kill $FRONTEND_PID 2>/dev/null; cleanup; exit 0' INT TERM

# Portable: no `wait -n` (not in all Alpine/busybox sh builds).
wait "$FRONTEND_PID"
EXIT_CODE=$?
cleanup
exit "$EXIT_CODE"
