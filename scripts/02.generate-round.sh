#!/bin/sh

model="$1"
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

# running each round...
for f in "$tmpdir"/split-*; do
    echo "$(date +'%Y-%m-%d %H:%M:%S')": \
         Stage "$stage"/"$stages", \
         round "$round"/"$rounds", \
         file "$(basename "$f")" >&2
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

