#! /bin/awk -f

# tail.awk -- display last ten lines of input
# $Id$
# Carlos Duarte, 981101


BEGIN {
	NLINES=10
}

{ ++n; n%=NLINES; x[n] = $0 }

END {
	for (i=n+1; i<NLINES; i++)
		print x[i]
	for (i=0; i<=n; i++)
		print x[i]
}
