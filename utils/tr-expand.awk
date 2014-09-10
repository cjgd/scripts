#! /usr/bin/awk -f

# tr-expand.awk -- expands tr a-z constructs, sort of... 
# $Id: tr-expand.awk,v 1.1 1998/09/06 23:02:18 cdua Exp cdua $
# Carlos Duarte, 980710

# usage: echo a-z | tr-expand.awk

BEGIN {
ascii=" !\"#$%&'\''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]\
^_`abcdefghijklmnopqrstuvwxyz{|}~"
}

{
	s = $0
	n = length(s)
	for (i=1; i<=n; i++) {
		c = substr(s, i, 1)
		if (i+2<=n && substr(s, i+1, 1) == "-") {
			i += 2
			cc = substr(s, i, 1)
			j = index(ascii, c)
			jj = index(ascii, cc)
			if (j != 0 && jj>=j)
				printf "%s", substr(ascii, j, jj-j+1)
		} else 
			printf "%s", c
	}
	print ""
}

