#! /bin/sed -f

# soelim.sed -- produce sh(1) commands that do a soelim
# $Id: soelim.sed,v 1.1 1998/07/09 03:35:10 cdua Exp cdua $
# Carlos Duarte, 980623

# usage: sed -f soelim.sed files | sh 

1i\
sed "s/.//"<<\\eof
/^\.so/!{
	s/^/-/
	b end
}

i\
eof
s/^\.so//
s/^/cat &/
a\
sed "s/.//"<<\\eof

: end

$a\
eof

