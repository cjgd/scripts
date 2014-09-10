#! /bin/sed -f

# wc-w.sed -- count words
# $Id: wc-w.sed,v 1.2 1998/07/06 20:31:30 cdua Exp $ 
# Carlos Duarte, 960909

# count all words on input
# words are separated by tabs, newlines and spaces

# the buffer hold the count
1{
x
s/^/0/
x
}

s/^[	 ]*/\
/
ts
:t
s/^/w/
ts
:s
s/^\(.*\n\)[^ 	][^ 	]*[ 	]*/\1/
tt

s/\n.*$//

# the above, replaced all words by `w', and deleted everything else
# except newlines
# now the job to do, its only counting chars, but first, we must
# remove on char, to balance the extra newline present on all lines
# and not counted (not on pattern space)

/./!{
$g
$q
d
}
s/.//

x
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
# put count on line
x
tx

# update buffer with count
h

# on last line, all is done, so print the count
$!d
