.PHONEY: help


data/01.packages: scripts/01.list-binaries.sh
	./scripts/01.list-binaries.sh

data/02.tournament/stage-1: scripts/02.popularity-contest.sh data/1.packages

data/02.tournament/stage-%:
