#! /usr/bin/perl

# flatten.pl -- 
# 	Takes a directory with subdirectories and copies it to other directory 
#	with no subdirectories.  Files with same names are handled, and a 
#	reverse script is made in order to restore the original hierarchy.
# 
# cgd, 020320

use strict; 
use File::Copy;

if (@ARGV != 1) {
	print "usage: $0 dest-dir\n"; 
	print "  read file list from stdin\n"; 
	print "  send file mapping to dest-dir/unflatten.sh\n"; 
	exit(1); 
}

my $dest = shift; 
my %mymap; 
while (<>) {
	chomp; 
	my $source = $_; 
	do_copy(\%mymap, $source, $dest); 
}
do_script(\%mymap ,$dest); 
exit(0); 

#### 

sub do_copy {
	my $x = shift; 
	my $src = shift; 
	my $dst = shift; 

	my $xxx = $dst."/".basename($src); 
	my $destfile = $xxx; 
	my $cnt=0; 
	while ( -e $destfile ) {
		$cnt++; 
		$destfile = $xxx . "-" . $cnt; 
	}
	$x->{$src} = basename($destfile); 
	copy($src, $destfile); 
}

sub basename {
	local $_ = shift; 
	s#^.*/##; 
	return $_; 
}

sub do_script {
	my $x = shift; 
	my $dir = shift; 
	local (*F, $_); 
	open F, ">".$dest."/unflatten.sh" or die "can't create unflatten.sh: $!"; 
	my %key; 
	for my $k (keys %$x) {
		$_ = $k; 
		s,/[^/]*$,,; 
		my @a = split /\//; 
		my $p = shift @a; 
		for (;;) {
			$key{$p} = 1; 
			@a or last; 
			$p .= "/".scalar shift @a; 
		}
	}
	for (sort keys %key) {
		printf F "test -d '$_' || mkdir '%s'\n", $_;
	}
	for (keys %$x) {
		$x->{$_} eq $_ and next; 
		"./".$x->{$_} eq $_ and next; 
		printf F "mv '%s' '%s'\n", $x->{$_}, $_; 
	}
	close F; 
}
