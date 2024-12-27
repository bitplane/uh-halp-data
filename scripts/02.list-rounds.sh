#!/bin/sh

set -e

stage=$1
rounds=$2

for round in $(seq $rounds); do
    echo data/02.tournament/round-"$stage"."$round"
done

