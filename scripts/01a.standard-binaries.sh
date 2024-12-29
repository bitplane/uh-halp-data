#!/bin/sh

docker run --rm ubuntu bash -c "
ls -1 /bin/;
ls -1 /usr/bin/;
ls -1 /sbin;
ls -1 /etc/alternatives | grep -Ev '\.gz$';
" | sort | uniq
