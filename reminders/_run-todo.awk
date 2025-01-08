/^\[.*\]$/ {
	ts = substr($0, 2, length($0) - 2)
	ok = (date(ts, "%s") <= now)
	next
}

ok && $0 !~ /^\s*$/
