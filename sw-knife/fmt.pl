#! /usr/bin/perl

# fmt.pl -- a simple perl based formatter, as described at perl man pages
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 981129

format =
^<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<~~
$_
.

$/ = '';
while (<>) {
	s/\s*\n\s*/ /g;
	write;
	print "\n"; 
}
