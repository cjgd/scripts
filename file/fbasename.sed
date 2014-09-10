#! /bin/sed -f 

# fbasename.sed -- strip directory component from paths
# $Id: fbasename.sed,v 1.2 1998/07/06 21:45:49 cdua Exp $
# Carlos Duarte, 960909/980706

# usage: fbasename file  
# or
# usage: find path -print | fbasename
# 
# 
# this is a basename, but read filenames from stdin
#
# each line contains the path and a possible suffix
# 
# this will produce one output line per input line, with the filename
# component of path, with the (possible) suffix removed

## use this if filenames are not clean (i.e. contains erroneous 
## extra spaces around them)
#s/^[ 	]*//
#s/[ 	]*$//
#
#tc
#:c

s/[ 	][ 	]*/\
/
ta

s/\/*$//
s/.*\///
b

:a

h
s/.*\n//
x
s/\n.*//

s/\/*$//
s/.*\///

tb
:b
G
s/^\(.*\)\(.*\)\n\2$/\1/
t

P
d
