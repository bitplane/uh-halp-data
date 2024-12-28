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
3. Install all those packages into a docker container. It'll be big.
4. Extract all the help files. Manpages too maybe?
5. Use llama to generate a narrative about how people generally use each program
6. Combine the docs and the narrative with uh-halp description to generate
   training data.
7. Filter the data - get rid of things that don't look right.
8. Fine tune a small model with the generated data
9. Squish it, push it
10. Sell underpants

## Ideas

### TODO

#### Musty haves

* shell builtins in the binary list.
* Parse `/etc/alternatives` because these are missing
* Popularity contest needs to filter GUI apps.
* Add tests / test framework.
* Docker image + data publish scripts
* ¿que halp? - translate training data

#### Never to have

* Look at other package sources (brew, pip, npm, cpan, rubygems, go)
* Mac + Windows specific stuff
* use `Provides`/`Depends` etc package metadata to get alternatives and ++priority
* Detect command subcommand pattern with nested --halps going on 
* manpage dumps from docker image

### data

* Break this apart and do the same for brew
* Get collections of scripts and summarize each line,
  "what was the author thinking" -> "what would they ask 'uh' to get this line"

### model

* Snag Gemini Nano from Chrome?
* LaMini-T5-223M?
* qwen2.5-coder?


## Notes

* Packages that hang during install: mythexport

