#! /usr/bin/awk -f 

# center.awk -- center lines 
# $Id: center.awk,v 1.1 1998/07/09 02:00:58 cdua Exp cdua $
# Carlos Duarte, 980707

# usage: awk -f center -- [-w width] files... 
# or   : awk -f center files...
BEGIN {
	if (ARGC > 1) {
		if (ARGV[1] ~ /^-[0-9]/) {
			width = substr(ARGV[1], 2)
			ARGV[1] = ""
		} else if (ARGV[1] == "-w" && ARGC > 2) {
			width = ARGV[2]
			ARGV[1] = ""
			ARGV[2] = ""
		}
	}
	if (width == 0)
		width = 72
}
		
{ printf "%*s\n", int((width+length)/2), $0 }
