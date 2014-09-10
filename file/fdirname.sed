#! /bin/sed -f

# fdirname.sed -- dirname applied on an input of filenames
# $Id: fdirname.sed,v 1.2 1998/07/06 21:36:41 cdua Exp $
# Carlos Duarte, 960909/980706

# usage: find path -print | fdirname
# 
# fdirname acts like dirname, but read file names from stdin
#
# prints the directory component of a path


# special case: `/' is given
/^\/$/c\
/

## strip trailing `/'s if any
#s/\/*$//
# strip trailing filename
s/[^/]*$//

# if get no chars after these, then we have current dir (things like
# `bin/ src/' were given)
/./!c\
.

# delete the trailing `/'
# ("/usr/bin/ls" --> "/usr/bin/", this makes "/usr/bin")
s/\/$//

# no chars? then its the root (/)
/./!c\
/
