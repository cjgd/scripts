#! /usr/bin/perl

# fortune-query.pl -- search fortune database for some perl pattern
# $Id$ 
# Carlos Duarte <cgd@teleweb.pt>, 981122/000123

use strict;

## options and global data here
my %o = (
	### comment this to autodetect by default
	# fdir => '/usr/local/share/games/fortunes'
); 

sub usage {
	print <<EOM;
usage: $0 [-d dir] pattern

  -h      this help
  -d dir  specify fortune data files directory
  -a      tries to autodetect fortune directory
EOM
	@_ and print "\n", join("\n", @_), "\n"; 
	exit;
}

O: while (defined(my $opt = shift)) {
	$opt eq "-h" and usage;
	$opt eq "-a" and do { undef $o{'fdir'}; next O; }; 
	$opt =~ /^-d/ and do {
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$o{'fdir'} = $opt; 
		next O; 
	}; 
	###
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}
@ARGV == 0 and usage("need a pattern to search for"); 
$o{'pat'} = shift; 
@ARGV == 0 or usage("no args after pattern accepted"); 

if ($o{'fdir'} eq "") {
	# tries to autodetect fortune dir
	my $p; 
	local $_; 
	for (split /:/, $ENV{'PATH'}) {
		$p = "$_/fortune"; 
		-x $p and goto FOUND; 
	}
	die "sorry: could not find fortune program"; 
FOUND: 
	local *F; 
	open F, $p or die "can't read fortune program $p: $!"; 
	local $/; undef $/;
	$_ = <F>; 
	close F; 
	my ($d) = m#(/[-\w./]+/fortunes)\b#; 
	####print $d, "\n"; exit; 
	$d eq "" and die "couldn't autodetect fort dir"; 
	$o{'fdir'} = $d; 
} 

my ($dir, $pat) = ($o{'fdir'}, $o{'pat'});
$/ = "%"; 
opendir D, $dir or die "can't open dir $dir: $!"; 
while (defined(my $f = readdir(D))) {
	local $_ = "$dir/$f"; 
	next if /\.dat$/; 
	####print $_,"\n"; 
	next unless -f $_; 
	local *F; 
	open(F, $_) or do {
		warn "can't open $_: $!"; 
		next; 
	}; 
	while (defined($_ = <F>)) {
		s/%$//; 
		s/\n*$/\n/; 
		print if /$pat/oi; 
	}
	close(F); 
}
closedir(D); 
