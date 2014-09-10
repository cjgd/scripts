#! /bin/sed -f

# from_roman.sed -- output bc(1) code that convert roman to decimal
# $Id: from_roman.sed,v 1.1 1998/07/07 01:42:11 cdua Exp cdua $
# Carlos Duarte, 980707

# usage: echo MCXLIII | sed -f from_roman.sed | bc

s/$/\
0M1000CM900D500CD400C100XC90L50XL40X10IX9V5IV4I1/

s/^/\
/
ta
:a
s/\n\(..\)\(.*\n.*[0-9]\)\1\([1-9]0*\)/\3+\
\2\1\3/
tb
s/\n\(.\)\(.*\n.*[0-9]\)\1\([1-9]0*\)/\3+\
\2\1\3/
tb

s/\n/0; ">>> error:/
s/\n.*/"/
#q
b

:b
/\n\n/!ba
s/.\n\n.*$//

