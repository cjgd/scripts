#! /bin/sed -f

# ghanoi.sed -- a "graphical" implementation of hanoi game, in sed!
# $Id: ghanoi.sed,v 1.1 1998/09/06 23:17:35 cdua Exp cdua $
# Carlos Duarte, 980712

# usage: echo xxx | sed -f han.sed 
#            solves 3 disks problem
#        echo 12345 | sed -f han.sed
#            solves 5 disks problem
#
# i.e. the length of each line, is the number of disks to solve
#

#        
# well known recursion: 
# h(n, l, m, r)
# 	if (n>=1)
# 		h(n-1, l,r,m)
# 		print move from l to r
# 		h(n-1, m,l,r)
# 
# 
# equivs to : 
#
# h(n, l,m,r)
# 	while (n>=1)
# 		h(n-1, l,r,m)
# 		print move from l to r 
# 		swap l,m
#		n = n-1
# 
# which is the one that is implemented

# ... @n:lmr$

s/././g
s/.*/@&:123/

: recurse
/^@:/!{
	s/^@.\([^:]*:.\)\(.\)\(.\)/@\1\3\2&/
	b recurse
	:r1

	s/^@[^:]*:\(.\).\(.\)/move from \1 to \2\
&/
	# this...
	#P
	# or these two, for a pretty print of results
	b pretty
	:return

	s/.*\n//

	s/^@.\([^:]*:\)\(.\)\(.\)/@\1\3\2/
	b recurse
}
s/^@[^:]*:...//
/./b r1
d

: pretty
i\

P
x
/./!{
	g
	s/^.*@//
	s/....$//
	s/./1/g
}
G
/\n.*1 to 2.*\n/{s/1/2/; bp2; }
/\n.*1 to 3.*\n/{s/1/3/; bp2; }
/\n.*2 to 1.*\n/{s/2/1/; bp2; }
/\n.*2 to 3.*\n/{s/2/3/; bp2; }
/\n.*3 to 1.*\n/{s/3/1/; bp2; }
/\n.*3 to 2.*\n/{s/3/2/;      }

:p2
s/\n.*$/,;/
tp3
:p3
/^,/!{
	s/^\(.*\)1\(.*\),\(.*\)$/\1\2,1\3o /; tp4; s/$/  /; tp4; :p4
	s/^\(.*\)2\(.*\),\(.*\)$/\1\2,2\3o /; tp5; s/$/  /; tp5; :p5
	s/^\(.*\)3\(.*\),\(.*\)$/\1\2,3\3o /; tp6; s/$/  /; tp6; :p6
	bp3
}
:p7
/;./{
s/......$/\
&/
s/^\(.*\)\n\(.*\)$/  \2\
\1/
P
s/^.*\n//
bp7
}
i\
  = = = \
  1 2 3
s/[^123]//g
x
b return
