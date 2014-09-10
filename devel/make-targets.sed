#! /bin/sed -nf

# make-targets.sed -- tries to catch all targets on a Makefile
# $Id: make-targets.sed,v 2.4 1998/07/09 02:48:25 cdua Exp cdua $
# Carlos Duarte, 960801/970602

#
# the purpose of this is to be used on the complete feature
# of tcsh... so it should be simple and fast
# 
# the name of the makefile, unfortunelly, must be hard coded on the
# tcsh `complete' definition, and should be "Makefile"
#

# init the buffer to \n 
1{
x
s/^/\
/
x
}

# take care of \ ended lines
:a
/\\$/{
	N
	ba
}
s/\\\n//g

y/	/ /

# delete all comments
/^ *#/d
s/\([^\\]\)#.*$/\1/

# register vars: VAR = def
# only of the form: VAR = one_word_def
# - accept also spaces, i.e. more than one word
# 
/=/!be
/[A-Za-z_0-9-]\+ *= *[\$(){} A-Za-z_0-9./-]\+ *$/{

	s/ *= */=/
	s/^ *//
	s/ *$//
	H
	d
}

:e

# get targets
/:/!d
/^[\$(){}A-Za-z_0-9./-]\+[^:]*:[^=]\?/!d
s/:.*//

# this line is a make target, now check for vars and do replace
#
/[\$({]/!bb
tc
bc
:d
s/\n.*//
tc
:c
/\$[({][A-Za-z_0-9-]\+[)}]/!bb

G
s/\(\$[{(]\)\([A-Za-z_0-9-]\+\)\([)}]\)\(.*\n\n.*\)\n\2=\([^\
]*\)/\5\4/
td

s/\n.*//
:b

# final filter
# dont print *.[hco] targets: usually deps are included on makefiles
/\.[och]$/d
/\.[och] /d
p

