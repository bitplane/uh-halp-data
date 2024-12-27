#!/bin/sh

set -e

input_name="$1"

# remove:
# 1. paths + package names
# 2. things with a -version.number on the end
# 3. specific arch binaries
# 4. names.like.this
# 5. too-many-hyphen-names

cat "$input_name" | \
	awk '{n=split($1, bin, "/");
		print bin[n]}' | \
	grep -v -E '\-([0-9]+\.)*[0-9]+$' | \
	grep -v -E 'x86|arm|x64|ppc' | \
	grep -v -E '.*\..*\..*\.' | \
	grep -v -E '.*-.*-.*-'
