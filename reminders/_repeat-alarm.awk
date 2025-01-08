BEGIN {
	year = substr(today, 1, 4)
	month = substr(today, 6, 2)
}

function monday(day)
{
	day = year "-" month "-" day
	weekday = date(day, "%w")
	return date(day " + " (1 - weekday) " day", "%Y-%m-%d")
}

/^\[.*\]$/ {
	ok = 1
	$0 = substr($0, 2, length($0) - 2)
	n = split($0, ts, "-")
	if (n == 1)
	{
		day = ts[1]
	}
	else if (n == 2)
	{
		if (split(ts[1], mo, "%") == 2)
		{
			if ((month - mo[1]) % mo[2])
				ok = 0
		}
		else
		{
			if (month != ts[1])
				ok = 0
		}

		day = ts[2]
	}

	if (ok)
		print "\n[" monday(day) "]"
	next
}

ok && $0 !~ /^\s*$/ {
	print
}
