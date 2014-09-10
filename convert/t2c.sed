#! /bin/sed -f

# t2c.sed -- converts text, to C strings
# $Id: t2c.sed,v 1.2 1998/07/06 20:31:22 cdua Exp $ 
# Carlos Duarte, 960610/960804

#
# The purpose of this script is to construct C programs like this: 
# 
# 	printf("\
# common text
# ...
# 
# 
# ...
# last line of text
# 
# and then pipe through this filter, the portion between printf and the last
# line of text, and get a valid C statement
# 
# That's why, " is placed on last line, and not in first, for eg


# escape all special chars " and \ inside a string...
s/["\\]/\\&/g

# adds a \n\ to the end of each line, except the last, which gets \n"
s/$/\\n/
$!s/$/\\/
$s/$/"/
