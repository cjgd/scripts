#! /usr/bin/perl 

# rename.pl -- rename files by finding a fixed pattern and replace it by other
# Carlos Duarte, 031105

# a clone of the rename(1) utility present in most linux distributions

use strict; 

if (@ARGV < 3) {
	print "usage: $0 srcpat dstpat files...\n"; 
	exit 1; 
}

my $srcpat = shift;
my $dstpat = shift;

for (@ARGV) {
	my $old = $_;
	s/\Q$srcpat\E/$dstpat/; 
	my $new = $_;  
	$old eq $new and next; 
	print "$old -> $new\n"; 
	rename $old, $new; 
}

