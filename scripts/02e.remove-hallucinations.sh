#!/bin/sh
set -e

output="data/02.tournament/sorted-$1"
original="data/02.tournament/stage-1"

# Fail if files don't exist
: < "$output"
: < "$original"

# Remove hallucinations
grep -Fxf "$original" "$output" | \
    grep -v '^$'

