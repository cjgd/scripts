#! /usr/bin/perl -p

# unquote-printable -- convert =XX quote, to its 8 bit representation
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990208


s/=\n$//; 
s/=([0-9A-Fa-f]{2})/pack("C", hex($1))/ge; 

