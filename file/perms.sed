#! /bin/sed -f

# perms.sed -- convert 'ls -l' output in octal file permission modes
# $Id$
# Carlos Duarte <cgd@teleweb.pt>, 000601

#
# usage: ls -l | sed -f perms.sed 
# 

/^[d-][rwx-][rwx-][rwx-]/!d 

# get filename into hold space
h 
s/^.* //
x


# get rwxr--r-- into pat space
s/ .*$//
s/.//

# convert groups of rwx into octal, on pat space: 
# rw-r--r--:01234567 		
# rrrrww-,r--,r--:01234567   (remove from ^rr.. and :012.. until get to ^,)
# ,r--,r--:67

:c
s/$/:01234567/

s/./&&&&,/
s/,\(.\)/\1\1,/
s/,\(.\)/\1,/

ta
:a
/^,/bb
s/^-//
ta
s/.//
s/:./:/
ta
ba

# insert octal digit into hold buf
:b
H
x
s/\n.*:\(.\).*$/\1/
x

/,:/bout
s/,//
s/:.*$//
bc

:out
x
s/^\(.*\)\(...\)$/\2 \1/
