#!/bin/sh
set -e

model=$1
group_size="$2"
survivors="$3"
stage="$4"
round="$5"

tmpdir=/tmp/tournament-"$stage"-"$round"


# create tempdir
rm -r "$tmpdir" 2>/dev/null || true
mkdir -p "$tmpdir"
cp data/02.tournament/stage-"$stage" "$tmpdir/stage"

# preparing data
cat "$tmpdir/stage" | shuf > "$tmpdir"/shuffled
split -l $group_size -d -a 6 "$tmpdir/shuffled" "$tmpdir/split-"
total_split=$(ls -1 "$tmpdir"/split-* | wc -l)
count=0

# run each group
for f in "$tmpdir"/split-*; do
    count=$((count + 1))
    echo "$(date +'%Y-%m-%d %H:%M:%S')": \
         Stage "$stage"/"$tournament_stages", \
         round "$round"/"$tournament_rounds", \
         file "$count"/"$total_split" >&2
    (
        echo "Output $survivors CLI programs from the list below, order by how often they are manually typed."
        echo
        cat "$f"
        echo "Output $survivors items only. Do not add extra text. Ordered list."
    ) | ($model > "$f.filtered")
done

echo round over, dumping results for round-"$stage"."$round" >&2
cat "$tmpdir"/*.filtered | \
    cut -d ' ' -f 2- | \
    sort | \
    uniq | \
    grep -v ' ' # remove verbage

