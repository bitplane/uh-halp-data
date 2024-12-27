#!/bin/sh

set -e

stem="$1"
echo "$(echo "$stem" | cut -d '-' -f 2 | cut -d '.' -f 2 )"
