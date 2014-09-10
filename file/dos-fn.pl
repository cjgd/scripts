#! /usr/bin/perl

# dos-fn.pl -- convert long filenames to 8.3 restriction 
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 991013

use strict; 

sub usage {
	print <<EOM; 
usage: $0 [-h] [-n] files..

 -h  this help
 -n  no op
 -v  be verb
EOM
	exit; 
}

my %opts; 
while ($ARGV[0] =~ /^-/) {
	local $_ = shift @ARGV; 
	$_ eq "-h" and usage(); 
	$_ eq "-n" and do { $opts{'dont'}++; next; };
	$_ eq "-v" and do { $opts{'verb'}++; next; };
}

@ARGV or usage; 

my %dup; 
my @src; 
my @dst; 
for (@ARGV) {
	my ($name, $ext) = split /\./, $_, 2; 
	$name = substr($name, 0, 8); $name = canon($name); 
	$ext = substr($ext, 0, 3); $ext = canon($ext);
	push @src, $_; 
	push @dst, "$name.$ext"; 
	$dup{"$name.$ext"}++; 
}

for (keys %dup) {
	$dup{$_} = $dup{$_} != 1; 
}

while (@src && @dst) {
	my $src = shift @src; 
	my $dst = shift @dst; 
	my (@n, $n); 

	while ($dup{$dst} != 0) {
		if ($n == 0) {
			@n = split /\./, $dst; ## 2 elems
			$n = 1; 
		}
		my $name = substr($n[0], 0, 6-length("$n")); 
		$dst = "$name~$n~.$n[1]"; 
		$n++; 
	}
	do_rename($src, $dst); 
	$dup{$dst}++; 
}
exit; 

sub do_rename {
	my $src = shift; 
	my $dst = shift; 

	$src eq $dst and return 1; 
	if ( -e $dst ) {
		warn "trying to move $src -> $dst and $dst exists"; 
		return 0; 
	}
	print "$src -> $dst\n" if ($opts{'verb'});
	return 1 if ($opts{'dont'}); 
	rename $src, $dst or die "rename $src, $dst failed: $!"; 
	return 1; 
}

sub canon {
	local $_ = shift; 
	y/[-!#$&()@_~a-zA-Z0-9]//cd; 
	return lc $_; 
}

