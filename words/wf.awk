#! /usr/bin/awk -f

# wf.awk -- word frequency counter
# $Id: wf.awk,v 1.1 1998/07/09 02:02:31 cdua Exp cdua $
# Carlos Duarte, 980708

BEGIN {
	RS = "[^A-Za-z_]+"
}

{ x[$0]++ }

END {
	delete x[""]
	for (i in x)
		printf "%6d\t%s\n", x[i], i
}
