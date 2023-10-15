#!/bin/sh
set -e

>/dev/null type expr ffmpeg mktemp

range_expr() { >/dev/null expr "$1" : '[0-9:./]\+$'; }

if range_expr "$1"; then
	i=/tmp/master0.wav
elif [ $# -gt 0 ]; then
	i="$1"
	shift
fi

if [ $# -lt 1 ]; then
	>&2 cat <<-EOT
	$0 [source-file] range [range...] [out-file]

	Cut up an audio file and splice the cuts together.

	* If source-file is omitted, use /tmp/master0.wav as
	  the source.

	* If out-file is omitted, output the final splice at
	  /tmp/mix.wav

	Range describes the start and end timestamp of the cut,
	formatted with a slash:

	    [start]/[end]

	* With the start omitted, cut from the very beginning
	  of the audio.

	* With the end omitted, cut until the very end of the
	  audio.


	For example:

	    $0 test.wav /1:00 1:30/1:50 2:00/

	...Cuts test.wav from 0:00 until 1:00, then splice with
	a cut between 1:30 and 1:50, then splice with a final
	cut from 2:00 until the end of the file.
	EOT
	exit 1
fi

d="$(mktemp -d)"

trap 'rm -rf "$d"' EXIT

n=1

while [ $# -gt 0 ]; do
	if ! range_expr "$1"; then
		break
	fi

	a=${1%/*}
	b=${1#*/}

	a=${a:+-ss $a}
	b=${b:+-to $b}

	ffmpeg -i "$i" $a $b "$d/$n.wav"
	echo "file '$n.wav'" >> "$d/concat.txt"

	n=$((n + 1))
	shift
done

case $# in
	0)
		o=/tmp/mix.wav
		;;
	1)
		o="$1"
		;;
	*)
		>&2 echo "$1: range contains invalid characters"
		exit 1
esac

ffmpeg -f concat -i "$d/concat.txt" -y "$o"
