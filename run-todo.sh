#!/bin/sh
set -e
[ $# -eq 1 ]
cd "$(dirname "$0")"
awk \
	-v "now=$(date +%s)" \
	-f _common.awk \
	-f _run-todo.awk "$1" |
	while read -r line; do
		alarm now "$line"
	done
