#! /bin/sed -f

# uniq-d.sed -- print all duplicated uniq lines on a sorted input
# $Id: uniq-d.sed,v 1.2 1998/07/06 20:31:26 cdua Exp $ 
# Carlos Duarte, 960909/960909

# like `uniq -d'

$d
N
/^\(.*\)\n\1$/{
	s/.*\n//
	p
	:b
	$d
	N
	/^\(.*\)\n\1$/{
		s/.*\n//
		bb
	}
}
$d
D
