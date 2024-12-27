#!/bin/sh
set -e

old_file="data/02.tournament/sorted-$1"
new_file="data/02.tournament/stage-$2"

# Fail if the files don't exist
: < "$old_file"
: < "$new_file"

# new lines go to the top of the file
cat "$new_file" | sort | uniq

# old lines minus the new ones go to the end
grep -vFxf "$new_file" "$old_file"

