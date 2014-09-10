#! /bin/awk -f 

# toupper.awk -- convert input file names into upper case
# $Id: toupper.awk,v 1.1 1998/07/06 16:46:47 cdua Exp cdua $
# Carlos Duarte, 970928/971017

BEGIN {
	dirs="."
	if (ARGC >= 2) 
		dirs = ARGV[1]

	cmd="find " dirs " -type f -print"

	while ((cmd|getline)) {
		n = split($0, p, /\//);
		if (n && toupper(p[n]) != p[n]) {
			from=$0
			sub("/[^/]*$", "/" toupper(p[n])); 
			print "mv", from, $0
		}
	}
	close(cmd); 
}
