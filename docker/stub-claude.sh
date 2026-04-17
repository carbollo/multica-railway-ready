#!/bin/sh
# Placeholder so `multica` LoadConfig finds a "claude" on PATH in minimal images.
# Replace with a real Claude Code install to execute tasks (see Dockerfile.railway-daemon).
set -e
case "${1:-}" in
  --version | -v | version)
    echo "2.0.0"
    exit 0
    ;;
esac
echo "stub claude: install the real Claude Code CLI in this image to run agent tasks" >&2
exit 1
