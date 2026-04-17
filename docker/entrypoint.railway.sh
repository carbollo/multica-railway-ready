#!/bin/sh
set -e

# Railway injects $PORT for the process that must accept healthchecks (Next.js).
# Save it before we override $PORT for the Go backend.
PUBLIC_PORT="${PORT:-3000}"

# Internal API port — must differ from PUBLIC_PORT (Railway often sets PORT=8080).
BACKEND_PORT="${BACKEND_PORT:-8081}"

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

export PORT="$PUBLIC_PORT"
export HOSTNAME="${HOSTNAME:-0.0.0.0}"

sleep 1
if ! kill -0 "$BACKEND_PID" 2>/dev/null; then
  echo "Backend exited before frontend start" >&2
  exit 1
fi

echo "Starting frontend on ${PORT} (backend internal: ${BACKEND_PORT})..."
node /app/apps/web/server.js &
FRONTEND_PID=$!

trap 'kill $FRONTEND_PID 2>/dev/null; cleanup; exit 0' INT TERM

wait "$FRONTEND_PID"
EXIT_CODE=$?
cleanup
exit "$EXIT_CODE"
