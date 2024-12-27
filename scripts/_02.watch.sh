#!/bin/sh

cd data/02.tournament
for stage in stage*; do
	echo "$stage:\t$(cat "$stage" | wc -l)" 2>/dev/null
done

round="$(ls -1tr round* 2>/dev/null | grep -v 'tmp' | tail -n1)"
echo "$round:\t$(cat "$round" 2>/dev/null | wc -l)"

tournament_dir=$(ls -1trd /tmp/tournament* | tail -n1)

echo "$(ls -1 "$tournament_dir"/split-??????.filtered | wc -l)" / \
     "$(ls -1 "$tournament_dir"/split-?????? | wc -l)" | \
     figlet

ls -1tr "$tournament_dir"/*filtered | tail -n2 | xargs cat

