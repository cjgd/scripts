#! /bin/sed -f

# rev-lines.sed -- reverse all lines of input, i.e. first line became last, ...
# $Id: rev-lines.sed,v 1.2 1998/07/06 20:31:22 cdua Exp $
# Carlos Duarte, 960905/980706

1h
1d
G
h
$!d
## g
