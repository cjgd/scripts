#! /bin/sed -f

# tail.sed -- display last ten lines of a file
# $Id: tail.sed,v 1.3 1998/07/06 20:31:24 cdua Exp $
# Carlos Duarte, 960908/970517

#:a
#$q
#N
#1,10ba
#
#$!D

# the above SHOULD work, but doesnt!

:a
$q
N
11,$D
ba
