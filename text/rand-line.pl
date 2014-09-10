#! /usr/bin/perl

# rand-line.pl -- outputs N random lines from input
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 981225/990222

use strict 'vars'; 

sub usage {
	print <<EOM;
usage: $0 [-n NR] [files]

  -n      number of lines to output
EOM
	exit;
}

my $n; 
my ($opt); 
O: while (defined($opt = shift)) {
	$opt =~ /^-n/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$n = $opt; 
		next O; 
	}; 
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}
defined($n) or $n = 1; 

my @lines = <>; 
print $lines[int(rand @lines+0)] while ($n--); 
