#!/bin/sh

stem="$1"
echo "$(echo "$stem" | cut -d '-' -f 2 | cut -d '.' -f 1 )"
