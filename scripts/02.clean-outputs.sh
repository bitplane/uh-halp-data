#!/bin/sh
set -e

output="data/02.tournament/sorted-$1"
original="data/02.tournament/stage-1"

# Remove hallucinations
grep -Fxf "$output" "$original" | \
    grep -v '^$'

