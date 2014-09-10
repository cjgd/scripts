#! /usr/bin/awk -f 

# rand-line.awk -- output a random line from input 
# $Id: rand-line.awk,v 1.3 1998/11/18 01:18:52 cdua Exp cdua $
# Carlos Duarte, 971027/981118

BEGIN {
	srand()
	for (i=1; i<ARGC; i++) {
		s = ARGV[i]
		if (s !~ /^-/)
			break; 
		if (s == "-n" && ++i <ARGC) {
			ARGV[i-1] = ""
			n = ARGV[i]
			ARGV[i] = ""
		} else 
			break; 
	}
	if (n+0 == 0)
		n = 1
}


{
	lines[cnt++] = $0
}

END {
	while (n--) {
		d = int(rand()*cnt)
		print lines[d]; 
	}
}
