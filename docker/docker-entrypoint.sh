#!/usr/bin/env bash
set -Eeuo pipefail
confd -log-level ERROR -onetime -backend env || { echo "Error: Templating config files with environment variables failed" >&2 && exit 1; }

# Create directories that need to exist. For example, XTF expects the dir it
# writes indexes to to exist.
xargs < /opt/xtf/conf/required-dirs.txt mkdir -p

exec "$@"
