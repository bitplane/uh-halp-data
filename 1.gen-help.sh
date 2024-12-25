#!/bin/sh

rm -r help || true
mkdir -p help

for cmd in /bin/*; do
	echo $cmd
	output=help/"$(basename "$cmd")"

	timeout 5s "$cmd" --help >"$output"  2>&1 || \
		(rm "$output" && echo $cmd >> failed.txt)

done

