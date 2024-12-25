#!/bin/sh

alias llama3="docker exec -i ollama ollama run llama3"

dir=llama-summaries

mkdir -p "$dir"

for help in ./help/*; do
	cmd="$(basename "$help")"
	output="$dir"/"$cmd"

	[ -e "$output" ] && continue

	echo $cmd

	(
	echo "You are summarizing a given command. Your task is to produce a header in a fixed format, here is an example of the output:

COMMAND NAME: find
SUMMARY: finds files and folders
USAGE: searches a path for things the user is interested in, used in a huge number of ways. usually filtered with grep, summarized with wc, sliced with cut, and used in multi stage pipelines. Advanced users execute commands with it, combine with xargs, and solve novel problems with it.
IMPORTANCE: this is an old, but fundamentally important command.
MOST IMPORTANT ARGS: -name -name -depth -0 -exec -size
COMMONLY USED WITH: grep cut xargs less watch

The command is: $cmd

For your reference, the --help for this command is here:
"
		echo
		cat "$help"
	) | llama3 | tee "$output"
done

