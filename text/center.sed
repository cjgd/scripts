#! /bin/sed -f

# center.sed -- centers lines 
# $Id: center.sed,v 1.4 1998/07/06 20:31:10 cdua Exp $
# Carlos Duarte, 960804/970517

# center all lines of a file, on a 78 columns width
# to change that width, just change the number between \{\}, on last line

# del leading and trailing spaces
s/^[ 	]*//
s/[ 	]*$//

# center line, keep those two spaces areas bigger then 78... 
s/^/                                          /
s/$/                                          /

# delete extra chars
s/\(.*\)\(.\{78\}\)\1$/\2/
