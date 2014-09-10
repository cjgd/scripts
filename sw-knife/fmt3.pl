#! /usr/bin/perl

# fmt.pl -- yet another perl fmt(1)
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990228

$/ = ''; 
while (<>) {
	y/\n/ /; 
	while (length) {
		$l = substr($_, 0, 72); 
		$l =~ s/(\w*)$//; 
		print $l . "\n"; 
		$_ = $1 . substr($_, 72); 
	}
	print "\n"; 
}
