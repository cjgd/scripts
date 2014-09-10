#! /usr/bin/awk -f

# pmatch.awk -- find patterns
# $Id$
# Carlos Duarte, 990123/990202

# ABCABC matches all words abcabc, bcdbcd, cgdcgd, xyzxyz, ...

function canon(pat, 	next_num, n, p, i, this, result) {
	next_num = 1
	n = split(pat, p, "")
	for (i=1; i<=n; i++) {
		if (this[p[i]] == 0)
			this[p[i]] = next_num++
		result = result sprintf("%c", this[p[i]]+31)
	}
	return result
}

BEGIN {
	if (ARGC <= 1) {
		printf "usage: %s pattern [files]\n", ARGV[0]
		exit
	}
	pattern = canon(ARGV[1])
	for (i=1; i<=ARGC; i++)
		ARGV[i] = ARGV[i+1]
	ARGC --
}

{ for (i=1; i<=NF; i++) 
	if (canon($NF) == pattern)
		print $NF; 
}
