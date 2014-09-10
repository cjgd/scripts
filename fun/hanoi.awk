#! /usr/bin/awk -f

# hanoi.awk -- generate hanoi moves 
# $Id: hanoi.awk,v 1.1 1998/09/06 23:02:37 cdua Exp cdua $
# Carlos Duarte, 980712/980722

# usage: ./hanoi.awk -- -m1 4   use method 1, to solve 4 disks problem
# usage: ./hanoi.awk -- -m2 6   use method 2, to solve 6 disks problem
# usage: ./hanoi.awk -- -m3  	use method 3, to solve 3 (default) disks problem

# recursive algorithm (two recursive calls)
function h1(n, l, m, r) {
	if (n>=1) {
		h1(n-1, l,r,m)
		printf "move from %d to %d\n", l, r
		h1(n-1, m,l,r)
	}
}

# recursive also, but avoid tail recursion
function h2(n, l, m, r, 	t) {
	while (n>=1) {
		h2(n-1, l,r,m)
		printf "move from %d to %d\n", l, r
		n=n-1
		t = l
		l = m
		m = t
	}
}

# return the kth smaller, 0 based
# the index of x is returned; x[0..2]
function select_smaller(x, k, 	c0,c1,c2,o) {
	c0 = substr(x[0],1,1)+0; if (!c0) c0 = 9999
	c1 = substr(x[1],1,1)+0; if (!c1) c1 = 9999
	c2 = substr(x[2],1,1)+0; if (!c2) c2 = 9999
	if (c0<c1) {
		if (c0<c2) 
			if (c1<c2)
				o="012"
			else 
				o="021"
		else
			o="201"
	} else {
		if (c1<c2)
			if (c0<c2)
				o="102"
			else 
				o="120"
		else	
			o="210"
	}
	return substr(o,k+1,1)+0
}

# algorithm: 
# while true
# 	move small disk to left
# 	if one tower is full, exit
# 	move second small disk, to the remaining peg
# 
# l, m, r, not used
function h3(n, l, m, r, 	x, i, from, to, c) {
	for (i=1; i<=n; i++)
		x[0] = x[0] "" i 
	x[1] = ""
	x[2] = ""

	for (;;) {
		from = select_smaller(x, 0)
		to = (from+1)%3
		c = substr(x[from],1,1)
		x[from] = substr(x[from],2)
		x[to] = c x[to]
		printf "move from %d to %d\n", from+1, to+1

		if ((length(x[0])!=0)+(length(x[1])!=0)+(length(x[2])!=0)==1)
			break; 

		from = select_smaller(x, 1)
		to = 3-from-to
		c = substr(x[from],1,1)
		x[from] = substr(x[from],2)
		x[to] = c x[to]
		printf "move from %d to %d\n", from+1, to+1

	}

}

BEGIN {
	for (i=1; i<ARGC; i++) {
		if (ARGV[i] ~ /^-m/)
			method = substr(ARGV[i], 3)
		else break
	}
	if (i<ARGC)
		n = ARGV[i]
	if (n+0==0)
		n = 3
	print "n =", n
	method += 0
	if (method <= 1)
		h1(n, 1,2,3)
	else if (method == 2)
		h2(n, 1,2,3)
	else 
		h3(n, 1,2,3)
}

