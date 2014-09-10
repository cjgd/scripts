#! /usr/bin/perl 

# remove-binfiles.pl -- remove all non-text files recursively
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990516

use File::Find; 

sub usage { print "usage: $0 [-n] [dirs...]\n"; exit 2; }

my $fn; 
if ($ARGV[0] eq "-n") {
	shift; 
	$fn = sub { -f $_ && ! -T _ and print $File::Find::name, "\n"; }; 
} else {
	$fn = sub { -f $_ && ! -T _ and unlink $File::Find::name; }; 
}
@ARGV or usage; 
find($fn, @ARGV); 
