#! /usr/bin/awk -f

# month.awk -- print current month, like cal
# $Id: month.awk,v 1.1 1998/07/09 02:01:42 cdua Exp cdua $
# Carlos Duarte, 980707

BEGIN {
	m[1] = 31
	m[2] = 28
	m[3] = 31
	m[4] = 30
	m[5] = 31
	m[6] = 30
	m[7] = 31
	m[8] = 31
	m[9] = 30
	m[10] = 31
	m[11] = 30
	m[12] = 31

	cmd="date +'%d:%m:%Y:%w'"
	cmd | getline date
	close(cmd)

	split(date, x, /:/)
	print "Su Mo Tu We Th Fr Sa"
	w = (x[4]+700-x[1]+1)%7
	for (i=0; i<w; i++) {
		printf "  "
		if (i!=w) printf " "
	}
	
	d = m[x[2]+0]
	for (i=1; i<=d; i++) {
		printf "%2d", i
		printf (++w%7 == 0) ? "\n" : " "
	}
	print ""
}

