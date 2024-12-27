# So we can actually have some persistence
.ONESHELL:

MAX_PACKAGES=5000

all: data/03d.docker-build
	# finished? really? give yourself a pat on the back


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
data/01.binaries: data/01b.ubuntu-binaries-and-packages data/01a.ubuntu-bin scripts/01c.combine.sh
	@echo "01 - Combining binary lists"
	@./scripts/01c.combine.sh > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 2: Popularity contest 
data/02a.popularity-contest: data/01.binaries
	@echo "02 - Running popularity contest"
	@timestamp=$$(date -u +%Y-%m-%d_%H%M%S)
	@./scripts/02.popularity_contest.py data/01.binaries data/02a.popularity-contest --output-dir data > "$@.$$timestamp.tmp"
	@cp "$@.$$timestamp.tmp" "$@"

## Step 3a: Package priority
data/03a.package-priority: data/02a.popularity-contest scripts/03a.package_priority.py
	@echo "03 - Calculating package priority"
	@./scripts/03a.package_priority.py > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 3b: Limit number of packages
data/03b.limited-packages: data/03a.package-priority
	@echo "03 - Limiting to $(MAX_PACKAGES) packages"
	@head -n $(MAX_PACKAGES) $< | cut -d ' ' -f 2 > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 3c: Get binary names
data/03c.binary-names: data/01b.ubuntu-binaries-and-packages data/03a.package-priority scripts/03c.get_binary_names.py
	@echo "03 - Extracting binary names"
	@cat data/01a.ubuntu-bin > "$@.tmp"
	@./scripts/03c.get_binary_names.py data/01b.ubuntu-binaries-and-packages data/03b.limited-packages >> "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 3d: Build Docker image
data/03d.docker-build: data/03c.binary-names scripts/03d.Dockerfile
	@echo "03 - Building Docker image"
	docker build -t package-installer -f scripts/03d.Dockerfile .
	@touch "$@"
