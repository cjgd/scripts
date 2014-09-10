#! /bin/sed -f

# uniq-u.sed -- uniq lines on a sorted input
# $Id: uniq-u.sed,v 1.2 1998/07/06 20:31:27 cdua Exp $ 
# Carlos Duarte, 960909/960910

# print all uniq lines on a sorted input: no copies of duplicated lines
# like `uniq'

$b
N
/^\(.*\)\n\1$/!{
	P
	D
}

:c
$d
s/.*\n//
N
/^\(.*\)\n\1$/bc
D
