#! /bin/sed -f

# capit_iii.sed -- capitalize words 
# 
# $Id: capit_iii.sed,v 1.2 1998/07/06 20:32:46 cdua Exp $
# Carlos Duarte, 970528

# Idea: 
# . take care from word to word
# . if current word start with [a-z] convert _that_ char to upper
# . paste this word and space after to end of line (after \n) 
#
# . when a \n is seen at first char of line, we dont have
#   any more words to take care

s/$/\
/
s/^\([^A-Za-z]*\)\(.*\n\)/\2\1/

: main
/^\n/b exit
/^[a-z]/ {
	h
	s/\(.\).*/\1/
	y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/
	G
	s/\n.//
}
s/^\([A-Za-z]*[^A-Za-z]*\)\(.*\n.*\)/\2\1/
b main
	
: exit
s/.//

