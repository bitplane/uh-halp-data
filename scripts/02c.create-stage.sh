#!/bin/sh
set -e

for f in $*; do
    : < $f || exit 1
    cat $f
done | uniq | shuf
