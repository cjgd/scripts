#! /bin/sed -f

# dotify.sed -- right justify text, with dots
# Carlos Duarte <cgd@mail.teleweb.pt>, 991110
#

/^ *$/b 
/^.\(..\)*$/s/$/ /
s/$/ . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ./
s/^\(.\{60\}\).*$/\1/

######  ^^  set column width here 
