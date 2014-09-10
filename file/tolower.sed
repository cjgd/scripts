#! /bin/sed -nf

# tolower.sed -- convert file names to lower case... 
# usage: find dir -type f -print | tolower.sed | sh -x 

# $Id: tolower.sed,v 1.2 1998/07/06 20:31:24 cdua Exp $
# Carlos Duarte, 960904/970514

# remove all trailing /s
s/\/*$//

# add ./ if there is no path, only filename
/\//!s/^/.\//

# save path+filename
h

# remove path
s/.*\///

# give up if I havent any upper case char
/[A-Z]/! d

# do conversion only on filename
y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/

# swap; now line contains original path+file, hold space contains conv filename
x

# add converted file name to line, which now contains something like
# path/file-name\nconverted-file-name
G

# now, transform path/fromfile\ntofile, into mv path/fromfile path/tofile
# and print it
s/^\(.*\/\)\(.*\)\n\(.*\)$/mv \1\2 \1\3/p
