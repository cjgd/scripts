#! /bin/sed -f 

# justify.sed -- justifies text on 65 column-width
# Carlos Duarte <cgd@teleweb.pt>, 000716

# more than this stays untouched
/.\{65\}/b
h

# squeeze blanks, remove then from start and end
s/  */ /g
s/^ //
s/ $//

# double/triple/etc... all spaces until get length>=65
ta
:a
/^.\{65\}/bb
s/ [^ ]/ &/g
ta

# while not exactly 65, remove spaces 
:b
tc
:c
/^.\{65\}$/bend
s/\([^ ]\)\(  *\) \([^ ].*[^ ]\)\2 \([^ ]*\)$/\1\2\3\2 \4/
tc

# more than 5 inserted spaces, aren't justified
:end
/     /x
