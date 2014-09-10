#! /usr/bin/awk -f 

# primes_ii.awk -- generate prime numbers
# $Id: primes_ii.awk,v 1.1 1998/07/09 02:01:53 cdua Exp cdua $
# Carlos Duarte, 980708

# usage: ./primes_ii.awk first n_to_produce
# or:    ./primes_ii.awk n_to_produce

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

	z=0
	primes[z++]=2
	primes[z++]=3
	primes[z++]=5
	primes[z++]=7

	for (k=0; k<z; k++) 
		if ((pp = primes[k]) >= p) {
			print pp
			if (--n == 0)
				exit
		}

	sr = 3		# sr, square root; test prime[k] <= sr
	s  = 9		# s, square; sr^2
	ns = 16		# ns, next square; (sr+1)^2

	for (pp=11;; pp+=2) {
		if (pp>=ns) {
			sr++
			s = ns
			ns = (sr+1)^2
		}
		is_p=1
		for (k=1; k<z && primes[k] <= sr; k++)
			if (pp%primes[k] == 0) {
				is_p=0
				break
			}
		if (is_p) {
			primes[z++] = pp; 
			if (pp>=p) {
				print pp
				if (--n == 0)
					exit
			}
		}
	}
}
