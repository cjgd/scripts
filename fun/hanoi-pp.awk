#! /usr/bin/awk -f

# hanoi-pp.awk -- hanoi pretty print, transform "move from x to y" into moves
# $Id: hanoi-pp.awk,v 1.1 1998/09/06 23:01:45 cdua Exp cdua $
# Carlos Duarte, 980722

# usage: hanoi.awk -- 5 | ./hanoi-pp.awk 

/^[ \t]*n[ =\t:-]/ {
	gsub(/[^0-9]/, "")
	n = $1+0
	next
}

function do_move(from, to, 	i) {
	if (!begun) {
		begun++; 
		for (i=1; i<=n; i++)
			x[0] = x[0] "" i
		x[1] = ""
		x[2] = ""
	}
	x[to] = substr(x[from],1,1) x[to]
	x[from] = substr(x[from],2)

	l0 = length(x[0])
	l1 = length(x[1])
	l2 = length(x[2])
	i=l0
	if (i<l1) i=l1
	if (i<l2) i=l2
	while (i) {
		printf "%s ", l0==i?"o":" "
		printf "%s ", l1==i?"o":" "
		printf "%s ", l2==i?"o":" "
		printf "\n"
		l0 -= l0==i
		l1 -= l1==i
		l2 -= l2==i
		i--
	}
	print "= = =\n1 2 3\n"
}

{
	print 
	gsub(/[^0-9]/, " ")
	gsub(/ +/, " ")
	do_move($1-1, $2-1)
}

