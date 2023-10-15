#!/bin/sh
>/dev/null type ffmpeg tr

if [ $# -ne 2 ] && [ $# -ne 3 ]; then
	>&2 cat <<-EOT
	$0 song-name [loop-seconds] bitrate-kbps

	Use /tmp/mix.wav to create an Vorbis Ogg file in the
	current directory. The file name is constructed by
	converting song-name to uppercase and prepending 'O_'
	to the front, like so:

	    O_<song-name>.ogg

	loop-seconds is used to construct the LOOPMS metadata,
	with millisecond precision. It has this format in the
	Ogg file:

		 LOOPMS=<s><mmm>

	If loop-seconds is omitted, the metadata is constructed
	so:

	    LOOPMS=0000

	Example:

	    $0 diduz 22.1 64

	...Creates O_DIDUZ.ogg with an average bitrate of 64
	kbps. LOOPMS=22100
	EOT
	exit 1
fi

case $# in
	3)
		s="$2"
		k="$3"
		;;
	*)
		s=
		k="$2"
		;;
esac

ffmpeg -i /tmp/mix.wav \
	-metadata "LOOPMS=$(printf '%.3f' "$s" | tr -cd 0-9)" \
	-c:a libvorbis -b:a "${k}k" -y \
	"O_$(echo "$1" | tr a-z A-Z).ogg"
