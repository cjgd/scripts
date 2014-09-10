#! /bin/sed -f

# rev-chars.sed -- reverse all chars of each line, keep line ordering
# $Id: rev-chars.sed,v 1.3 1998/07/06 20:31:21 cdua Exp $ 
# Carlos Duarte, 960905/960929

# 1. reject all empty lines, and all 1 chars only lines
# 2. place two markers, `\n' at beggining and end of line
# 3. swap first char after first marker with first before marker
# 4. goto 4 until there are at least those two chars 
# 
# -- `\n' is a good marker, because, by default, `\n' isn't ever seen

/../!b

s/.*/\
&\
/

ta
:a
s/\(\n.\)\(.*\)\(.\n\)/\3\2\1/
ta

s/\n//g
