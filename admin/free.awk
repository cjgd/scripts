#! /usr/bin/awk -f 

# free -- query on memory on a linux system

# $Id: free.awk,v 2.1 1998/07/09 02:26:45 cdua Exp cdua $
# Carlos Duarte, 960718/971117 

# This is a replacement for Linux command `free'

# output from /proc/meminfo
#
# :r! cat /proc/meminfo
# 
#         total:   used:    free:   shared:  buffers:
# Mem:  15712256 13377536  2334720  2629632 10600448
# Swap:  7221248        0  7221248
# 
# output from free command
#
# :r! free
#              total       used       free     shared    buffers
# Mem:         15344      13108       2236       2644      10352
# Swap:         7052          0       7052
# 
# :%s/^/# /g
# 

BEGIN {
	val=1024; 
	for (i=1; i<ARGC; i++) {
		if (ARGV[i] == "-k") 
			val = 1024; 
		else if (ARGV[i] == "-b")
			val = 1; 
		else {
			print "usage:", ARGV[0], "[-k|-b]"
			exit
		}
	}

	printf "        %10s %10s %10s %10s %10s\n", 
			"total", "used", "free", "shared", "buffers"
		
	
	rfile="/proc/meminfo"
	while (getline<rfile == 1) {
		if (/^[ 	]*Mem:/) {
			printf "Mem:    "
			for(i = 2; i <= NF; i++)
				printf "%10d ", $i / val

			print ""
			continue
		}

		if (/^[ 	]*Swap:/) {
			printf "Swap:   "
			for(i = 2; i <= NF; i++)
				printf "%10d ", $i / val

			print ""
			continue
		}
	}
	close(rfile)
	exit
}
