#! /bin/sed -f

# expand.sed -- expand tabs into spaces (tabs stop = 8)
# $Id: expand.sed,v 1.1 1997/11/05 02:24:30 cdua Exp $
# Carlos Duarte, 971105

s/^/\
/
ta
:a
s/\n	/        \
/; ta
s/\n\([^	]\)	/\1       \
/; ta
s/\n\(.[^	]\)	/\1      \
/; ta
s/\n\(..[^	]\)	/\1     \
/; ta
s/\n\(...[^	]\)	/\1    \
/; ta
s/\n\(....[^	]\)	/\1   \
/; ta
s/\n\(.....[^	]\)	/\1  \
/; ta
s/\n\(......[^	]\)	/\1 \
/; ta
s/\n\(........\)/\1\
/; ta
s/\n//
