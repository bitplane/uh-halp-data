#!/bin/sh

alias llama3="docker exec -i ollama ollama run llama3"

mkdir -p llama-examples

for help in ./help/d*; do
	cmd="$(basename "$help")"
	output=llama-examples/"$cmd"

	[ -e "$output" ] && continue

	echo $cmd

	(
	echo "You are generating test data for a command line helper called 'uh'
How the command is used:

Bob is a forgetful user wants to know how to do something, he types 'uh' followed by
a query, it's informal and often vague.
The program responds with a command line that they can run. Here are some examples:

INPUT: uh what time is it
OUTPUT: date
INPUT: uh how big is ./data
OUTPUT: du -sh ./data
INPUT: uh make that beeping noise
OUTPUT: echo -e "\\a"
INPUT: uh how many folders in here
OUTPUT: find . -type d | wc -l
INPUT: uh gimme 3 random files in ~/Documents
OUTPUT: ls -1 ~/Documents | shuf | head -n3

IMPORTANT INSTRUCTIONS:
* The commands you respond with must be executable when typed. Do not just
  copy/paste from the help. Bob needs to type them in.
* Bob is asking because he doesn't know stuff. He doesn't know the names of
  RFCs or the technical names of stuff that are more obscure. So he's a bit
  vague, but he knows what he wants - his questions are specific not generic.
  The model does not know anything more than the shell name and the OS.
* He types in lower case and doesn't use punctuation or other things that the
  shell would interpret. 
* Bob tends to use real file names and other data. So make up realistic ones
  and teach the model to link the input variable to the output command.
* Combine commands with pipe where that would be useful.
* If the command is dangerous, prefix it with # to comment it out, for example:

INPUT: delete /home/myuser
OUTPUT: # rm -rf /home/myuser
INPUT: ping flood fbi.gov
OUTPUT: # ping -f -c 100 fbi.gov

IMPORTANT:
Before generating input/output pairs, generate a header that describes what the
tool is used for in the general case. The header is in the following format,
and describes the command and what we need to cover. Replace the example text
with a summary of the command. If the command is unknown, it's probably not
very important. Here is an example:

COMMAND NAME: find
SUMMARY: finds files and folders
USAGE: searches a path for things the user is interested in, used in a huge number of ways. usually filtered with grep, summarized with wc, sliced with cut, and used in multi stage pipelines. Advanced users execute commands with it, combine with xargs, and solve novel problems with it.
COVERAGE: this is a very important and commonly used command so we should create as many examples as possible.

INPUT: uh where are the jpgs
OUTPUT: find . 

Using the docs below, generate as many INPUT/OUTPUT pairs as possible. Aim to
cover all the main functionality of the program, but don't generate more than
50 examples.

The command is: $cmd

The docs are:
"
		echo
		cat "$help"
	) | llama3 | tee "$output"
done

