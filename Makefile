# Use phony targets for high-level steps
.PHONY: all build-tournament help generate-summaries help

# Popularity tournament parameters.
tournament_model      := "docker exec -i ollama ollama run llama3"
tournament_rounds     := 5
tournament_group_size := 200
tournament_survivors  := 20
tournament_stages:    := 10

all: run-tournament


## Step 1a: List default binaries for Ubuntu
data/01a.ubuntu-bin: scripts/01a.standard-binaries.sh
	@echo "01 - Getting standard binary names"
	@./scripts/01a.standard-binaries.sh > $@

## Step 1b: List all possible Ubuntu binaries
data/01b.ubuntu-binaries-and-packages: scripts/01b.all-ubuntu-binaries.sh
	@echo "01 - Getting all binary names"
	@./scripts/01b.all-ubuntu-binaries.sh > $@

## Step 1 final: combine the outputs
data/01.binaries: data/01b.ubuntu-binaries-and-packages scripts/01.combine.sh
	@echo "01 - Combining binary lists"
	@./scripts/01.combine.sh > $@



## Step 2: Sort binaries using LLM popularity tournament
run-tournament: data/02.tournament/sorted-$(tournament_stages)

data/02.tournament/stage-0:
	@echo "Creating dummy file for stage 0"
	@ln -S "$@" /dev/null

# Step 2a: Base case for the first stage
data/02.tournament/stage-1: data/01.binaries scripts/02.first-round.sh
	@echo "02 - getting initial stage data"
	@mkdir -p data/02.tournament
	@./scripts/02.first-round.sh "$<" > "$@"

# Combine round outputs to make the next stage
data/02.tournament/stage-%: $$(shell scripts/02.list-rounds.sh $* $(tournament_rounds))
	@echo "02 - Combining rounds for stage $*"
	@cat "$^" | sort | uniq | shuf > "$@"

# Run this round
data/02.tournament/round-%: data/02.tournament/stage-$$(shell scripts/02.get-stage.sh $@) scripts/02.generate-round.sh
	@stage=$$(shell scripts/02.get-stage.sh $@)
	@round=$$(shell scripts/02.get-round.sh $@)
	@echo "Generating data for stage $$stage/$(tournament_stages), round $$round/$(tournament_rounds)"
	@echo ./scripts/02.generate-round.sh \
		"$(tournament_model)" \
		"$(tournament_group_size)" "$(tournament_survivors)" \
		"$$stage" "$$round" > $@

# Base case for the first combo
data/02.tournament/sorted-1: data/02.tournament/stage-1
	@echo "02 - Sorting data for stage 1"
	@cat "$<" | shuf > "$@"

# combining data 
data/02.tournament/sorted-%: data/02.tournament/stage-$$(shell scripts/02.get-stage.sh $@) scripts/02.sort-data.sh
	@echo "02 - Sorting data for stage $*"
	@stage=$$(shell scripts/02.get-stage.sh $@)
	@previous_stage=$$(shell echo $$( $* - 1))
	@./scripts/02.sort-data.sh "$$stage" "$$previous_stage" > "$@"


## Step 3:
