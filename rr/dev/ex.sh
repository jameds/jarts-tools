#!/bin/sh
for f in *.wad; do
	wadcli "$f" -e TEXTMAP
	mv TEXTMAP.lmp "$(basename $f .wad).txt"
done
