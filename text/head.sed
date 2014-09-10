#! /bin/sed -f

# head.sed -- print first few lines of input
# $Id: head.sed,v 1.2 1998/07/06 20:31:20 cdua Exp $
# Carlos Duarte, 960909

# display first 10 lines of input

# the number of displayed lines can be changed, by changind the number
# before the `q' command to `n' where `n' is the number of lines wanted

10q
