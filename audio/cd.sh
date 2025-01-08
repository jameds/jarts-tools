#!/bin/sh
if [ $# -ne 1 ] && [ $# -ne 2 ]; then
	>&2 cat <<-EOT
	$0 source-file [silence-threshold]

	Decode an input audio file to WAV. The WAV file is
	output at /tmp/master0.wav

	Silence is automatically trimmed from the beginning of
	the audio.

	* silence-threshold is a decibel value.

	* If silence-threshold is omitted, a value of 60 dB is
	  assumed.
	EOT
	exit 1
fi

ffmpeg -i "$1" -vn -af \
	"silenceremove=start_periods=1:start_threshold=-${2:-60}dB" \
	-y /tmp/master0.wav
