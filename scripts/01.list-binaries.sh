#!/bin/sh

mkdir ./data

docker run --rm ubuntu bash -c "
apt update 1>&2
apt install apt-file lz4 --yes 1>&2
apt-file update 1>&2

lz4cat /var/lib/apt/lists/*.lz4 | grep -E '^bin\/|^usr\/bin\/'
" | tee data/01.bin-packages | sort | uniq
