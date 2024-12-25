#!/bin/sh

cd data/02.tournament
for stage in stage*; do
	echo "$stage:\t$(cat "$stage" | wc -l)" 2>/dev/null
done

round="$(ls -1tr round* 2>/dev/null | tail -n1)"
echo "$round:\t$(cat "$round" 2>/dev/null | wc -l)"

echo "$(ls -1 /tmp/tournament/split-??????.filtered | wc -l)" / \
     "$(ls -1 /tmp/tournament/split-?????? | wc -l)" | \
     figlet

ls -1tr /tmp/tournament/*filtered | tail -n1 | xargs cat

