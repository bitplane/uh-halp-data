# Generating data for uh-halp model

Making a dataset for command line help completion.

## Requirements

* Run on Ubuntu
* Install Docker
* Install make

It uses Docker, so it won't work in a container.

## Steps

1. Get a list of all binaries in Ubuntu's package manager
2. Do a tournament using llama to figure out which ones are most important
3. Install all those packages into a docker container. It's 90GB and is
   [here](https://hub.docker.com/repository/docker/bitplane1/uh-halp-data-binaries/).
4. Extract all the help files and manpages.
5. **YOU ARE HERE ->** Use llama to generate a narrative about how people
   generally use each program.
6. Combine the docs and the narrative with uh-halp description to generate
   training data.
7. Filter the data - get rid of things that don't look right.
8. Fine tune a small model with the generated data
9. Squish it, push it
10. Sell underpants

## Ideas

### TODO

#### Musty havelys

* shell builtins in the binary list.
* Add `/etc/alternatives` because our list of those are minimal.
* Detect command subcommand pattern with nested --halps going on 
* Add `info` helps too.
* Popularity contest needs to filter out GUI apps.
* ¿que halp? - translate training data

#### Never to have

* Look at other package sources (brew, pip, npm, cpan, rubygems, go)
* Mac + Windows specific stuff.
  * Might make a separate repo for these. 
* use `Provides`/`Depends` etc package metadata to get alternatives and
  ++priority
* Add tests / test framework.

### data

* Break this apart and do the same for brew
* Get collections of scripts and summarize each line,
  "what was the author thinking" -> "what would they ask 'uh' to get this line"

### model

* Snag Gemini Nano from Chrome?
* LaMini-T5-223M?
* qwen2.5-coder?


## Notes for AI assistants

* You will have been given a project snapshot with `git-dump`. Which is the
  following alias:
  `alias git-dump='git diff 4b825dc642cb6eb9a060e54bf8d69288fbee4904 HEAD'`.
  If you can run code and don't have this dump in your context, clone this
  repo and run it.
* The ideas and notes listed in this file are mainly notes for the human
  rather than instructions. Your main focus should be on the "you are here"
  marker at the top of this readme, if there is one, then the "must have"
  TODO section after that. Stay on target.
* It is important to remember that some steps take a long time to run, so
  take care not to introduce cache-blowing changes.

