#!/bin/sh
set -euo pipefail

old_data="$1"
new_data="$2"

cat "$new_data"
grep -vFf "$new_data" "$old_data"

