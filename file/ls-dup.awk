#! /bin/awk -f

# ls-dup.awk -- find duplicated names within first few characters
# $Id: ls-dup.awk,v 1.1 1998/10/06 01:02:04 cdua Exp cdua $
# Carlos Duarte, 980927

# usage: ls-dup.awk -- -n 3  => finds files on current dir, that start
#			        with the same three characters

BEGIN {
	if (ARGC > 2 && ARGV[1] == "-n")
		len = ARGV[2]+0

	printing = 0
	if (len == 0)
		len = 4

	cmd =  "ls -1F"

	while ((cmd|getline)>0) {

		if (substr(prev, 1, len) == substr($1, 1, len)) {
			if (!printing) {
				print "======"
				print prev
				printing = 1
			}
			print $1
		} else {
			printing = 0
		}

		prev = $1
	}
}
