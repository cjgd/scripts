#! /bin/sed -f

# wc-c.sed -- count chars
# $Id: wc-c.sed,v 1.2 1998/07/06 20:31:29 cdua Exp $ 
# Carlos Duarte, 960804/960909

# count all chars of input, kind of `wc -c' 

# the buffer hold the count
x
1s/^/0/

# we have a line, so at least there is one char: the `\n' 
tx
:x
s/9\(_*\)$/_\1/
tx
s/^\(_*\)$/0\1/
s/ \(_*\)$/0\1/
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

# get back to the line
x

# for each char in the line, increment the count
tc
:c
s/.//
x
tx

# on last line, all is done, so print the count, and quit
$b

# put current line (which has been swapped with the count) to the buffer
h
d
