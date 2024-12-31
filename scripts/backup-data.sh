#!/bin/sh

today=$(date +"%Y-%m-%d")

tar -czvf data.bak/$today.data_log.tar.gz data log
