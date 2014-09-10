#! /bin/sed -f

# cat-b.sed -- number nonblanks lines
# $Id: cat-b.sed,v 1.3 1998/07/09 02:47:15 cdua Exp cdua $ 
# Carlos Duarte, 960909/980706

# copy all lines of input, prefixing only nonblank lines by its number, 
# kind of `cat -b'

# init counter
1{
	x
	s/^/0/
	x
}

# for blanks, don't incr count, but print
/./!b

# increment counter
x
td
:d
s/9\(_*\)$/_\1/
td
s/^\(_*\)$/0\1/
s/8\(_*\)$/9\1/
s/7\(_*\)$/8\1/
s/6\(_*\)$/7\1/
s/5\(_*\)$/6\1/
s/4\(_*\)$/5\1/
s/3\(_*\)$/4\1/
s/2\(_*\)$/3\1/
s/1\(_*\)$/2\1/
s/0\(_*\)$/1\1/
s/_/0/g

# printf "%6d"
s/^/      /
s/^.*\(......\)/\1/

G
s/\n/	/p
s/	.*//
s/ *//
h
d
