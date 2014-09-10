#! /bin/awk -f 

# compact-list.awk -- compacts a numeric ordered list
# $Id$ 
# Carlos Duarte <cgd@teleweb.pt>, 000626

# example: echo 1 2 3 4 10 11 13 | tr ' ' \\n | awk -f compact-list.awk
# produces: 1-4, 10-11, 13
# 

function do_it() { 
	if (first) {
		if (prev-first >= 1)
			printf "%s%s-%s", comma, first, prev; 
		else
			printf "%s%s", comma, first; 
		comma = ", "
	}
	first=prev=$1 
}

BEGIN { prev= -99 }
$1 == prev+1 { prev=$1; next }
{ do_it() } 
END { do_it(); printf "\n"  } 
