#! /bin/sed -f

# t2roff.sed -- changes text, for inclusion on roff documents
# $Id: t2roff.sed,v 1.1 1998/07/06 20:32:33 cdua Exp $
# Carlos Duarte, 980706

## vertically shorten empty lines 
#/^ *$/{
#c\
#.sp .3v
#}

s/\\/&e/g

## handles special stuff: _ *
#s/_/\\v'-.1v'_\\v'.1v'/g
#s/\*/\\v'.1v'*\\v'-.1v'/g

s/^/\\\&/

