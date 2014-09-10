#! /bin/sed -nf

# toupper.sed -- convert file names to upper case... 
# usage: find dir -type f -print | toupper.sed | sh -x 

# $Id: toupper.sed,v 1.4 1998/07/09 02:48:42 cdua Exp cdua $
# Carlos Duarte, 960904/970514

# remove all trailing /s
s/\/*$//

# add ./ if there is no path, only filename
/\//!s/^/.\//

# save path+filename
h

# remove path
s/.*\///

# give up if I havent any lower case char
/[a-z]/! d

# do conversion only on filename
y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/

# swap; now line contains original path+file, hold space contains conv filename
x

# add converted file name to line, which now contains something like
# path/file-name\nconverted-file-name
G

# now, transform path/fromfile\ntofile, into mv path/fromfile path/tofile
# and print it
s/^\(.*\/\)\(.*\)\n\(.*\)$/mv \1\2 \1\3/p
