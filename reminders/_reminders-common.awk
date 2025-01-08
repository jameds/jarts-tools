function sh(cmd)
{
	cmd | getline
	close(cmd)
	return $0
}

function date(ts, fmt)
{
	return sh("date -d '" ts "' +" fmt)
}
