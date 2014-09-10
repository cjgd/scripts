#! /usr/bin/perl 

# netscape-cache.pl -- try to associate URL names with netscape cache files
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990923

# should open index.db, but tie fails to do that, so issua a string on it

use strict;
my ($cache, $ok); 

my $cnt = 1; 
open CMD, "strings index.db|" or die $!; 
while (<CMD>) {
	chomp;
	if (/^..\/cache/) {
		$cache = $_; 
		$ok = 0; 
		next; 
	}
	if (/^image\//) {
		$ok = 1; 
		next; 
	}
	if (/^(http|ftp):/) {
		next if ($ok == 0);
		s/^.*\///; 
		if ( $_ eq "" ) {
			$_ = "__$cnt"; $cnt++; 
		}
		while ( -e $_ ) {
			$_ = "__$cnt"; $cnt++; 
		}
		my $src = "/.netscape/cache/$cache";
		do_cp($src, $_) if ( -f $src); 
		next; 
	}
}

sub do_cp {
	my $src = shift;
	my $dst = shift; 
	#print "$src -> $dst\n"; return; 
	local (*S, *D); 
	open S, $src or die "$src: $!"; 
	open D, ">".$dst or die "$dst: $!"; 
	print D <S> or die "write/read: $!"; 
	close S or die "close $src: $!"; 
	close D or die "close $dst: $!" 
}
