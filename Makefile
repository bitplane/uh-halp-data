# Use phony targets for high-level steps
.PHONY: all build-tournament help generate-summaries help

tournament_rounds := 5
tournament_stages: := 10

all: data/01.binaries

## Step 1a: List default binaries for Ubuntu
data/01a.ubuntu-bin: scripts/01a.standard-binaries.sh
	@echo "Getting standard binary names"
	@./scripts/01a.standard-binaries.sh > $@

## Step 1b: List all possible Ubuntu binaries
data/01b.ubuntu-binaries-and-packages: scripts/01b.all-ubuntu-binaries.sh
	@echo "Getting all binary names"
	@./scripts/01b.all-ubuntu-binaries.sh > $@

## Step 1 final: combine the outputs
data/01.binaries: data/01b.ubuntu-binaries-and-packages scripts/01.combine.sh
	@echo "Combining binary lists"
	@./scripts/01.combine.sh > $@



## Step 2: Sort binaries by popularity
build-tournament: data/02.tournament/stage-$(tournament_stages)

# Base case for the first stage
data/02.tournament/stage-1: data/01.binaries scripts/02.popularity-contest.sh
	# run a script that starts the first tournament stage
	@echo "Building stage-1"
	@mkdir -p data/02.tournament
	@./scripts/02.popularity-contest.sh > $@

# Combine the outputs of subsequent stages
data/02.tournament/stage-%: $$(shell scripts/02.list-rounds.sh $$* $(tournament_rounds))
	@echo "Combining rounds for stage $^*"
	@cat $^ | sort | uniq | shuf > $@

	
