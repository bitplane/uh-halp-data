# So we can actually have some persistence
.ONESHELL:


all: data/03a.package-priority
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

## Step 2: Popularity contest 
data/02a.popularity-contest: data/01.binaries
	@echo "02 - Running popularity contest"
	@timestamp=$$(date -u +%Y-%m-%d_%H%M%S)
	@./scripts/02.popularity_contest.py data/01.binaries > "$@.$$timestamp.tmp"
	@cp "$@.$$timestamp.tmp" "$@"

## Step 3a: Package priority
data/03a.package-priority: data/02a.popularity-contest scripts/03a.package_priority.py
	@echo "03 - Calculating package priority"
	@./scripts/03a.package_priority.py > "$@.tmp"
	@mv "$@.tmp" "$@"
