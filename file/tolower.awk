#! /bin/awk -f 

# tolower.awk -- convert input file names into lower case
# $Id: tolower.awk,v 1.2 1998/07/09 02:30:04 cdua Exp cdua $
# Carlos Duarte, 970928/971017

# usage: ./tolower.awk dirs | sh 
# eg: 
# 	tolower.awk .. | sh 
# 	tolower.awk $HOME/ftp | sh -x
# 
# for moving to uppers, replace `tolower(p[n])', per `toupper(p[n])'
# on two places
# 

BEGIN {
	dirs="."
	if (ARGC >= 2) 
		dirs = ARGV[1]

	cmd="find " dirs " -type f -print"

	while ((cmd|getline)) {
		n = split($0, p, /\//);
		if (n && tolower(p[n]) != p[n]) {
			from=$0
			sub("/[^/]*$", "/" tolower(p[n])); 
			print "mv", from, $0
		}
	}
	close(cmd); 
}
