# So we can actually have some persistence
.ONESHELL:
.SHELLFLAGS := -c -e

MAX_PACKAGES=15000
PACKAGE_BLACKLIST=^pcp$$|^mythexport$$|^prewikka$$|^slapd$$|^mailman3-web$$|^freedombox$$

all:
	@bash -c "touch ./data/*"
	@$(MAKE) data/04.run-help-extractor
	# finished? really? give yourself a pat on the mouth

## Step 1a: List default binaries installed in Ubuntu.
data/01a.ubuntu-bin: scripts/01a.standard-binaries.sh
	@echo "01 - Getting standard binary names"
	@./scripts/01a.standard-binaries.sh > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 1b: List all possible Ubuntu binaries from all available packages
data/01b.ubuntu-binaries-and-packages: scripts/01b.all-ubuntu-binaries.sh
	@echo "01 - Getting all possible binary names"
	@./scripts/01b.all-ubuntu-binaries.sh > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 1 final: combine the outputs into a list of binaries.
data/01.binaries: data/01b.ubuntu-binaries-and-packages data/01a.ubuntu-bin scripts/01c.combine.sh
	@echo "01 - Combining the binary lists"
	@./scripts/01c.combine.sh > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 2: Use LLM to rank the binaries in popularity order.
data/02a.popularity-contest: data/01.binaries
	@echo "02 - Running popularity contest"
	@timestamp=$$(date -u +%Y-%m-%d_%H%M%S)
	@./scripts/02.popularity_contest.py data/01.binaries data/02a.popularity-contest --output-dir data --log-dir log > "$@.$$timestamp.tmp"
	@cp "$@.$$timestamp.tmp" "$@"

## Step 3a: Prioritize the packages based on the binary rankings.
data/03a.package-priority: data/02a.popularity-contest scripts/03a.package_priority.py
	@echo "03 - Calculating package priority"
	@./scripts/03a.package_priority.py > "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 3b: Limit the number of packages based on how many we want to install.
data/03b.limited-packages: data/03a.package-priority
	@echo "03 - Limiting to $(MAX_PACKAGES) packages"
	@head -n $(MAX_PACKAGES) $< > "$@.tmp"
	@cut -d ' ' -f 2 "$@.tmp" > "$@.tmp2"
	@mv "$@.tmp2" "$@.tmp"
	@grep -Ev "$(PACKAGE_BLACKLIST)" "$@.tmp" > "$@.tmp2"
	@mv "$@.tmp2" "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 3c: Get binary names from the packages we installed, plus the defaults.
data/03c.binary-names: data/01b.ubuntu-binaries-and-packages data/03b.limited-packages scripts/03c.get_binary_names.py
	@echo "03 - Extracting binary names"
	@cat data/01a.ubuntu-bin > "$@.tmp"
	@./scripts/03c.get_binary_names.py data/01b.ubuntu-binaries-and-packages data/03b.limited-packages >> "$@.tmp"
	@mv "$@.tmp" "$@"

## Step 3d: Install the packages into a Docker container, in batches.
data/03d.docker-build: scripts/03d.build-docker.sh scripts/03d.Dockerfile scripts/03d.Dockerfile-base data/03b.limited-packages
	@echo "03 - Building Docker images for binaries"
	@scripts/03d.build-docker.sh
	@touch "$@"

## Step 4: Extract --help texts for each binary
data/04.run-help-extractor: data/03d.docker-build scripts/04.run-help-extractor.sh
	@echo "04 - Running --help extractor in Docker"
	@scripts/04.run-help-extractor.sh
	@touch "$@"
