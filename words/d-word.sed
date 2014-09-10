#! /bin/sed -f

# d-word.sed -- find consecutive duplicated words on text
# $Id: d-word.sed,v 1.1 1998/07/09 02:46:30 cdua Exp cdua $
# Carlos Duarte, 980707

# usage: sed -f d-word.sed textfiles 
# or : echo 'this this is a test' | ./d-word.sed 
# produce: this

: start
## makes this caseless 
#y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
s/$/ /
s/[^_A-Za-z0-9][^_A-Za-z0-9]*/:/g

: again
/:./!b next_line
s/:/,/
/^\([^,]*\),\1:/!b next

h
s/,.*$//
p
g
ta
:a
s/^\(.*\),\1:/\1,/
ta

: next
tb
:b
s/^[^,]*,//
b again

: next_line
$d
N
b start
