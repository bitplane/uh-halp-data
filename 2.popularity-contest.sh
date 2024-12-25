#!/bin/sh

alias llama3="docker exec -i ollama ollama run llama3"

mkdir -p popularity

tmpdir=/tmp/popularity

ls -1 ./help > popularity/1

for stage in $(seq 5); do
	for round in $(seq 2); do
		# remove tempdir
		rm -r "$tmpdir" || true
		mkdir -p "$tmpdir"
		cp popularity/"$stage" "$tmpdir/stage"

		cat "$tmpdir/stage" | shuf > "$tmpdir"/shuffled
		split -l 10 -d -a 4 "$tmpdir/shuffled" "$tmpdir/split-"

		for f in "$tmpdir"/split-*; do
			echo Stage "$stage", round "$round", file "$f"
			(
			echo "Pick the 5 most important commands and output them and nothing else. Numbered list:"
			echo
			cat "$f"
			) | (llama3 > "$f.filtered")
		done

		echo round over, saving results to popularity/"$stage"."$round"
		cat "$tmpdir"/*.filtered | \
			cut -d ' ' -f 2- | \
			sort | \
			uniq | \
			grep -v ' ' > popularity/"$stage"."$round"
	done

	echo finished stage "$stage", 
	cat popularity/"$stage".* | \
		sort | \
		uniq > popularity/"$((stage + 1))"
done

