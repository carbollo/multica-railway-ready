#!/bin/sh
set -e

# Railway assigns $PORT for the public HTTP service (frontend).
if [ -z "${PORT}" ]; then
  export PORT=3000
fi

# Backend remains internal to this container.
export BACKEND_PORT="${BACKEND_PORT:-8080}"
export PORT_BACKUP="$PORT"
export PORT="$BACKEND_PORT"

echo "Running database migrations..."
/app/migrate up

echo "Starting backend on ${BACKEND_PORT}..."
/app/server &
BACKEND_PID=$!

# Next.js standalone server uses PORT/HOSTNAME.
export PORT="$PORT_BACKUP"
export HOSTNAME="${HOSTNAME:-0.0.0.0}"

echo "Starting frontend on ${PORT}..."
node /app/apps/web/server.js &
FRONTEND_PID=$!

term_handler() {
  kill "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
}

trap term_handler INT TERM

# Exit if either process crashes.
wait -n "$BACKEND_PID" "$FRONTEND_PID"
EXIT_CODE=$?
term_handler
exit "$EXIT_CODE"
