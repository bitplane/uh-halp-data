# So we can actually have some persistence and do recursion
.ONESHELL:

# So we don't blow through our underpants and make a mess on the floor
SHELLFLAGS := -e
MAKEFLAGS := $(MAKEFLAGS) --no-print-directory

# Popularity tournament parameters.
tournament_model      := docker exec -i ollama ollama run llama3
tournament_rounds     := 5
tournament_group_size := 200
tournament_survivors  := 20
tournament_stages     := 6


all: data/02.tournament/results
	# finished? really? give yourself a pat in the mouth


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
data/01.binaries: data/01b.ubuntu-binaries-and-packages data/01a.ubuntu-bin scripts/01.combine.sh
	@echo "01 - Combining binary lists"
	@./scripts/01.combine.sh > "$@.tmp"
	@mv "$@.tmp" "$@"

#
# 🐉 WARNING - here be fragility 🐉
#
#   Touch on pain of.. pain.
#
# Lessons learned:
# 
# 🚫 Makefiles are parsed to build recipes and then built on a second pass. So
#    you can't pass build-time variables into dependencies to make them
#    recursive.
# 🖕 Of course variables are blank if not defined. Missing parameters move in
#    mysterious ways.
# 🐚 .ONESHELL means you can actually use variables. Otherwise each step runs in
#    a subshell and you can't.
# 🛑 You can set -e to fail on errors, but pipes will still fail silently.
# 🍆 sh doesn't support '-o pipefail', so you're boned there unless you use
#    external scripts or nested ugliness.
# ⚠️  './some-script > $@' will give you a partial output if the script fails,
#    which may pass that mess on to the next stage. Save to a tmp file and move
#    into place.
# 💩 A .PHONY target. Of course it’s phony. Fake as hell. Call their deps
#    children like they've got some innocence or whatever. But no, they just
#    keep getting dragged along, doing the same thing over and over again, like
#    a bunch of suckers. Every single time—boom, overwritten. Doesn’t matter what
#    was there before, something real, something you worked on—gone. Goddamn phony
#    targets. Phony steps. It’s all a bunch of crap, if you ask me.
#    goddamn time, stepping in your crappy data data a second time.
# 💥 Steps that rely on a script that changed, same deal.
# 💣 Debugging make with -d is worthless without -rR too because of all the
#    spam. Use echo and exit 1 while you hack.
#
# For these reasons, and me not regenerating the data due to how long it
# takes, there might be errors to do with steps I've cached. So make sure you
# back up your data.
#

## Step 2: Sort binaries using LLM popularity tournament
data/02.tournament/results: data/02.tournament/sorted-$(tournament_stages)
	@echo "02 - removing hallucinations"
	@./scripts/02e.remove-hallucinations.sh $(tournament_stages) > "$@.tmp"
	@mv "$@.tmp" "$@"

# Step 2a: Base case for the first stage
data/02.tournament/stage-1:
	@# run this manually so we don't blow our data away if it changes
	@make data/01.binaries
	@echo "02 - getting initial stage data"
	@mkdir -p data/02.tournament
	@./scripts/02a.first-stage.sh "data/01.binaries" > "$@.tmp"
	@mv "$@.tmp" "$@"

# Combine round outputs to make the next stage
data/02.tournament/stage-%:
	@previous_stage=$$(($* - 1))
	@rounds=$$(./scripts/02.list-rounds.sh $$previous_stage $(tournament_rounds))
	@$(MAKE) data/02.tournament/stage-$$previous_stage $$rounds
	@echo "02 - Combining rounds for stage $*"
	@./scripts/02c.create-stage.sh $$rounds > "$@".tmp
	@mv "$@.tmp" "$@"

# Run this round
data/02.tournament/round-%:
	@stage=$$(./scripts/02.get-stage.sh $*)
	@round=$$(./scripts/02.get-round.sh $*)
	@$(MAKE) data/02.tournament/stage-"$$stage"
	@echo "Generating data for stage $$stage/$(tournament_stages), round $$round/$(tournament_rounds)"
	@export tournament_stages=$(tournament_stages)
	@export tournament_rounds=$(tournament_rounds)
	@./scripts/02b.generate-round.sh \
		'$(tournament_model)' \
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
	@$(MAKE) "data/02.tournament/stage-$$stage"
	@$(MAKE) "data/02.tournament/sorted-$$previous_stage"
	@echo "02 - Sorting data for stage $$stage"
	@./scripts/02d.sort-stage.sh "$$previous_stage" "$$stage" > "$@.tmp"
	@mv "$@.tmp" "$@"

