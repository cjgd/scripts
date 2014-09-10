#! /usr/bin/perl

# suck-massage.pl -- cluster suck retrieved files, by subject
# Carlos Duarte <cgd@mail.teleweb.pt>, 991128

# usage: suck-massage.pl * | sh -x

use strict; 

my %x; 
while (<>) {
	/^Subject: / or next;
	my @a = split /:/, $_, 2; 
	push @{ $x{ substr($a[1], 0, 10) } }, $ARGV; 
	close ARGV;
}

$,=" "; 
for (keys %x) { 
	print "uudeview -o -d -i", @{$x{$_}}, "\n"; 
} 
