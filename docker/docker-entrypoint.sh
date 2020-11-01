#!/usr/bin/env bash
set -Eeuo pipefail
confd -log-level ERROR -onetime -backend env || { echo "Error: Templating config files with environment variables failed" >&2 && exit 1; }
exec "$@"
