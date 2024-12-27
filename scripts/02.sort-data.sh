#!/bin/sh
set -e

old_file=data/02.tournament/"$1"
new_file=data/02.tournament/"$2"

cat "$new_file"
grep -vFf "$new_file" "$old_file"

