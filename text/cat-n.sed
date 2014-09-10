#! /bin/sed -f

# cat-n.sed -- number input lines 
# $Id: cat-n.sed,v 1.3 1998/07/09 02:47:46 cdua Exp cdua $
# Carlos Duarte, 960909/980706

# copy all lines of input, prefixed by its number, kind of `cat -n'

# switch to buffer
x

# init the counting
1s/^/0/

# increment the count: first line == number 1
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

# format the number like printf's `"%6d"'
s/^/      /
s/^.*\(......\)/\1/

# append the line to the number, and write: "<number>\t<line>"
G
s/\n/	/p

# after printing the line, transform the line into the number, and
# store it on buffer again
s/	.*//
s/ *//
h
d
