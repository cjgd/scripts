#! /usr/bin/perl

# freq-char.pl -- measure frequency of chars... 
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990703

use strict; 
use vars qw(%a); 

undef $/; 
map { $a{ord($_)}++ } split // while (<>); 
for (sort { $a <=> $b } keys %a) {
	printf "%02x  %s  %d\n", $_,$_>=32&&$_<127?chr:".",$a{$_}; 
}

