#!/bin/sh
set -e
[ $# -eq 2 ]
cd "$(dirname "$0")"
awk \
	-v "today=$(date +%Y-%m-%d)" \
	-f _common.awk \
	-f _repeat-alarm.awk "$1" >> "$2"
