#!/bin/sh

alias llama3="docker exec -i ollama ollama run llama3"

model="$1"
group_size="$2"
survivors="$3"

tmpdir=/tmp/tournament


for stage in $(seq "$stages"); do
	for round in $(seq "$rounds"); do
        
        # if it already exists, don't recreate
		[ -e "$output_dir"/round"$stage"."$round" ] continue

		# remove tempdir
		rm -r "$tmpdir" || true
		mkdir -p "$tmpdir"
		cp "$output_dir"/stage-"$stage" "$tmpdir/stage"

		cat "$tmpdir/stage" | shuf > "$tmpdir"/shuffled
		split -l $group_size -d -a 6 "$tmpdir/shuffled" "$tmpdir/split-"

		for f in "$tmpdir"/split-*; do
			echo "$(date +'%Y-%m-%d %H:%M:%S')": \
			     Stage "$stage"/"$stages", \
			     round "$round"/"$rounds", \
			     file "$(basename "$f")"
			(
			echo "Output $survivors CLI programs from the list below, order by how often they are manually typed."
			echo
			cat "$f"
			echo "Output $survivors items only. Do not add extra text. Ordered list."
			) | (llama3 > "$f.filtered")
		done

		echo round over, saving results to round"$stage"."$round"
		cat "$tmpdir"/*.filtered | \
			cut -d ' ' -f 2- | \
			sort | \
			uniq | \
			grep -v ' ' > "$output_dir"/round"$stage"."$round"
	done

	echo finished stage "$stage", 
	cat "$output_dir"/round"$stage".* | \
		sort | \
		uniq > "$output_dir"/stage-"$((stage + 1))"
done

for stage in $(seq "$stages" -1 2); do
	# todo: combine	
done

