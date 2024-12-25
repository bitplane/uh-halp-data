# Generating data for uh-halp model

Making a dataset for command line help completion.

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

### data

* Break this apart and do the same for brew
* Get collections of scripts and summarize each line,
  "what was the author thinking" -> "what would they ask 'uh' to get this line"

### model

* Snag Gemini Nano from Chrome?
* LaMini-T5-223M?
* qwen2.5-coder?

