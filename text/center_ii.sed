#! /bin/sed -f

# center_ii.sed -- centers lines 
# $Id: center_ii.sed,v 1.1 1998/07/06 20:31:48 cdua Exp $
# Carlos Duarte, 980706

# centers lines on a 72 width
# for width changing, make number of dots on /.../b equal to wanted width

s/^[ 	]*//
s/[ 	]*$//

:b
/......................................................................../b
s/.*/ & /
bb
