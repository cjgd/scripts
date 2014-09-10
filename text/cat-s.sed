#! /bin/sed -nf

# cat-s.sed -- squeezes out all consecutive blank lines into a single blank
# $Id: cat-s.sed,v 1.3 1998/07/06 20:30:55 cdua Exp $
# Carlos Duarte, 960601/970519

/^[ 	]*$/d

:a
p
n
//!ba

:b
n
//bb

i\

ba
