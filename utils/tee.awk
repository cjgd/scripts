#! /usr/bin/awk -f

# tee.awk -- implement tee(1) on awk
# $Id: tee.awk,v 1.1 1998/07/09 02:02:04 cdua Exp cdua $
# Carlos Duarte, 980708

# usage: prog | awk -f tee.awk -- -f file 

BEGIN {
	for (i=1; i<ARGC; i++) {
		s = ARGV[i]
		if (s == "-a") 
			append++
		else if (s == "-f")
			do_flush++
		else 
			break
		ARGV[i] = ""
	}

	for (; i<ARGC; i++) {
		files[z++] = ARGV[i]
		ARGV[i] = ""
	}
}

{
	if (append)
		for (i=0; i<z; i++)
			print >> files[i]
	else 
		for (i=0; i<z; i++)
			print > files[i]
	print 
	if (do_flush)
		fflush()	# () stdout only, fflush("") for all files
}
