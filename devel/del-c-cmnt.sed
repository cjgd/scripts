#! /bin/sed -f

# del-c-cmnt.sed -- remove all comments on C code
# $Id: del-c-cmnt.sed,v 1.3 1998/07/06 20:31:17 cdua Exp $ 
# Carlos Duarte, 960610/970220

/\/\*/!b
:x
/\*\//!{
	N
	bx
}
s/\/\*.*\*\///
