#! /bin/sed -f

# unexpand.sed -- convert sequences of spaces to tabs, if can
# $Id: unexpand.sed,v 1.1 1997/11/05 02:24:43 cdua Exp $
# Carlos Duarte, 971105

s/^/\
/
ta
:a
s/\n\([^ ][^ ][^ ][^ ][^ ][^ ][^ ][^ ]\)/\1\
/; ta
s/\n\([^ ][^ ][^ ][^ ][^ ][^ ][^ ]\) /\1	\
/; ta
s/\n\([^ ][^ ][^ ][^ ][^ ][^ ]\)  /\1	\
/; ta
s/\n\([^ ][^ ][^ ][^ ][^ ]\)   /\1	\
/; ta
s/\n\([^ ][^ ][^ ][^ ]\)    /\1	\
/; ta
s/\n\([^ ][^ ][^ ]\)     /\1	\
/; ta
s/\n\([^ ][^ ]\)      /\1	\
/; ta
s/\n\([^ ]\)       /\1	\
/; ta
s/\n        /	\
/; ta

s/\n//
