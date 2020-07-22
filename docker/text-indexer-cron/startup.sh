#!/bin/sh
echo "indexing data..."

/opt/xtf/bin/textIndexer -index index-cudl
/opt/xtf/bin/textIndexer -index index-cudl-tagging

echo "starting cron..."
cron -f
