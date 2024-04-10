BEGIN {
	FS="[ ;]"
}

$1=="thing" {
	thing=$3
	scale=0
}

$1=="mobjscale" {
	scale=$3
}

$1=="type" {
	type=$3
}

$1=="}" {
	if (thing)
	{
		if (type == 2010 && scale)
			print FILENAME, thing, scale
		thing=0
	}
}
