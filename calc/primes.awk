#! /usr/bin/awk -f 

# primes.awk -- output primes 
# $Id: primes.awk,v 1.2 1998/07/09 02:28:31 cdua Exp cdua $ 
# Carlos Duarte, 960611/980706

# awk -f primes.awk first-prime number-of-primes
# 
# dispay `number-of-primes' primes after (inclusive) `first-prime' 
# to produce a table (for inclusion on a C program), use: 
# 
# 	./primes.awk 9 9|sed 's/$/,/'|column -xc 64|sed 's/^/<TAB>/; $s/.$//'
# 

BEGIN {
	if (ARGC == 2) {
		n = ARGV[1]
	} else if (ARGC == 3) {
		p = ARGV[1]
		n = ARGV[2]
	} else if (ARGC != 1) {
		print "usage: ", ARGV[0], "[[first-prime] nprimes]"
		exit
	}
	if (p<2) p = 2
	if (n<1) n = 1

	while (p<4) {
		print p++
		if (--n == 0)
			exit
	}
		
	for (p=p+(p%2==0);; p+=2) {
		for (j=3; (j*j) <= p; j += 2)
			if ((p%j) == 0)
				break

		if(j*j > p) {
			print p
			if (--n == 0)
				break
		}
	}
}
