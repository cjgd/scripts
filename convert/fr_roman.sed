#! /bin/sed -f

# fr_roman.sed -- from roman (to decimal)
# $Id: fr_roman.sed,v 1.1 1998/07/07 01:25:05 cdua Exp $
# Carlos Duarte, 980707

# usage: echo MCMXCVIII | sed -f fr_roman.sed 
# output: 1998
# 
# converts roman literals to decimal
# some input error checking is done, but not all cases are covered
# (bigger constructions following smallers, for instance)
# 

# build table, all possible constructs that evaluate to [1-9]0* are here
1{
x
s/$/0/
s/$/I1/
s/$/II2/
s/$/III3/
s/$/IV4/
s/$/V5/
s/$/VI6/
s/$/VII7/
s/$/VIII8/
s/$/IX9/
s/$/X10/
s/$/XX20/
s/$/XXX30/
s/$/XL40/
s/$/L50/
s/$/LX60/
s/$/LXX70/
s/$/LXXX80/
s/$/XC90/
s/$/C100/
s/$/CC200/
s/$/CCC300/
s/$/CD400/
s/$/D500/
s/$/DC600/
s/$/DCC700/
s/$/DCCC800/
s/$/CM900/
s/$/M1000/
s/$/MM2000/
s/$/MMM3000/
x
}

# converts from MMXXII to 2000,20,2, from lookup table
s/^/\
/
G

ta
:a
s/\n\(..*\)\(.*\n.*[0-9]\)\1\([1-9]0*\)/\3,\
\2\1\3/
tb

s/\n/>>> error:/
s/\n.*//
#q
b

:b
/\n\n/!ba
s/\n\n.*$//

# convert from 2000,20,2, to 2022. this is not trivial! 
#
# steps: 
# 2000,20,2, -> 2000<20>2,	<20> is the work digit
:d
s/,/</
te
:e
s/,/>/
tf

# exit point here: contains `2022,' so, remove the `,' and go
s/.$//
b

# 2000<20>2, -> 2000,:20<20>2,	: is the cursor for changing the 20 in ,:20 
#				into 00 (for later, remove these from 2000)
:f
s/<\(.*\)>/,:\1&/

# 2000,:20<20>2, -> 2000,00:<20>2,
tc
:c
s/:[0-9]/0:/
tc

# 2000,00:<20>2, -> 2020,2,	convert next digit
s/\(0*\),\1:<//
s/>/,/
bd
