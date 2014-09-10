#! /usr/bin/awk -f 

# shuffle-lines.awk -- output all input lines on random order
# $Id: shuffle-lines.awk,v 1.2 1998/07/09 02:29:52 cdua Exp cdua $
# Carlos Duarte, 971027

BEGIN {
	srand()
}

{
	x[i++] = $0
}

END {
	for (j=0; j<i; j++) {
		n = int(rand()*(i-j))	# 0 .. i-j-1
		t = x[j]
		x[j] = x[n]
		x[n] = t
	}

	for (j=0; j<i; j++) {
		print x[j]
	}
}

