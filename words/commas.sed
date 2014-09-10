#! /bin/sed -f

# commas.sed -- format a number (or anything else) into xx,xxx,xxx ...
# 
# $Id: commas.sed,v 1.2 1998/07/06 20:31:16 cdua Exp $
# Carlos Duarte, 970514


s/$/,/

ta
:a
s/\([^,]\)\(...,\)/\1,\2/
ta

s/.$//
