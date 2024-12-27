.PHONY: all build-tournament help generate-summaries help

# So we can actually have some persistence and do recursion
.ONESHELL:

# So we don't blow through our underpants and make a mess on the floor
SHELLFLAGS := -e -x

# Popularity tournament parameters.
tournament_model      := "'docker exec -i ollama ollama run llama3'"
tournament_rounds     := 5
tournament_group_size := 200
tournament_survivors  := 20
tournament_stages     := 10

all: run-tournament

## Step 1a: List default binaries for Ubuntu
data/01a.ubuntu-bin: scripts/01a.standard-binaries.sh
	@echo "01 - Getting standard binary names"
	@./scripts/01a.standard-binaries.sh > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 1b: List all possible Ubuntu binaries
data/01b.ubuntu-binaries-and-packages: scripts/01b.all-ubuntu-binaries.sh
	@echo "01 - Getting all binary names"
	@./scripts/01b.all-ubuntu-binaries.sh > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 1 final: combine the outputs
data/01.binaries: data/01b.ubuntu-binaries-and-packages scripts/01.combine.sh
	@echo "01 - Combining binary lists"
	@./scripts/01.combine.sh > "$@.tmp"
	@mv "$@.tmp" "$@"



## Step 2: Sort binaries using LLM popularity tournament
run-tournament: data/02.tournament/sorted-$(tournament_stages)

data/02.tournament/stage-0:
	@echo "Creating dummy file for stage 0"
	@echo > "$@" 

# Step 2a: Base case for the first stage
data/02.tournament/stage-1: data/01.binaries scripts/02.first-round.sh
	@echo "02 - getting initial stage data"
	@mkdir -p data/02.tournament
	@./scripts/02.first-round.sh "$<" > "$@.tmp"
	@mv "$@.tmp" "$@"

# Combine round outputs to make the next stage
data/02.tournament/stage-%:
	@previous_stage=$$(($* - 1))
	@rounds=$$(./scripts/02.list-rounds.sh $$previous_stage $(tournament_rounds))
	@echo $$rounds
	@make $$rounds
	@echo "02 - Combining rounds for stage $*"
	@cat $$rounds | sort | uniq | shuf > "$@".tmp
	@mv "$@.tmp" "$@"

# Run this round
data/02.tournament/round-%: scripts/02.generate-round.sh
	@stage=$$(./scripts/02.get-stage.sh $*)
	@round=$$(./scripts/02.get-round.sh $*)
	@make data/02.tournament/stage-"$$stage"
	@echo "Generating data for stage $$stage/$(tournament_stages), round $$round/$(tournament_rounds)"
	@export tournament_stages=$(tournament_stages)
	@export tournament_rounds=$(tournament_rounds)
	@./scripts/02.generate-round.sh \
		"$(tournament_model)" \
		"$(tournament_group_size)" "$(tournament_survivors)" \
		"$$stage" "$$round" > "$@.tmp"
	@mv "$@.tmp" "$@"

# Base case for the first combo
data/02.tournament/sorted-1: data/02.tournament/stage-1
	@echo "02 - Sorting data for stage 1"
	@cat "$<" | shuf > "$@.tmp"
	@mv "$@.tmp" "$@"

# combining sorted data
data/02.tournament/sorted-%:
	@mkdir -p data/02.tournament
	@stage=$$(./scripts/02.get-stage.sh "$@")
	@previous_stage=$$(($$stage - 1))
	@make "data/02.tournament/stage-$$previous_stage"
	@echo "02 - Sorting data for stage $$stage"
	@./scripts/02.sort-data.sh "$$stage" "$$previous_stage" > "$@.tmp"
	@mv "$@.tmp" "$@"

