#! /bin/sed -f

# del-sh-cmnt.sed -- delete all comments from a SH file
# $Id: del-sh-cmnt.sed,v 1.2 1998/07/06 20:31:19 cdua Exp $
# Carlos Duarte, 960610
#
#	... and SED, and CSH, and AWK, and MAKE... everything that
#	has comments starting with an `#'
#


# delete all lines begging with an `#'
#
/^#.*/d

# this should be applied only when text is allowed before `#' and from
# it begins comments...

# deals with escaped `#'s
s/\(.*[^\\]\)#.*$/\1/
