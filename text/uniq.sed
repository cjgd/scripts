#! /bin/sed -f

# uniq.sed -- uniq 
# $Id: uniq.sed,v 1.2 1998/07/06 20:31:28 cdua Exp $
# Carlos Duarte, 960909

# print all uniq lines on a sorted input: only one copy of a duplicated line
#   is print
#
# like `uniq'

:b
$b
N
/^\(.*\)\n\1$/{
	s/.*\n//
	bb
}

$b

P
D
