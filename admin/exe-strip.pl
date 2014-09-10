#! /usr/bin/perl

# exe-strip.pl -- strip executables, if not done already
# $Id$
# Carlos Duarte <cgd@teleweb.pt>, 990902

use strict; 

my %o; 
sub usage {
	print <<EOM;
usage: $0 [-n] [-h] FILES...

  -h      this help
  -n      dont! do nothing, just print what files would be stripped
  -v      be verbose
EOM
	@_ and print "\n", join("\n", @_), "\n";
	exit;
}

O: while (defined(my $opt = shift)) {
	$opt eq "-h" and usage;
	$opt eq "-n" and do { $o{'dont'}++; next O; }; 
	$opt eq "-v" and do { $o{'verb'}++; next O; }; 
	###
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}
@ARGV == 0 and usage; 

$| = 1; 
$" = " "; 
my @strip; 
my @sel; 
open CMD, "file @ARGV |" or die "file: $!"; 
while (<CMD>) {
	chomp; 
	/\bexecutable\b/ or next; 
	s/:\s+.*$//;
	push @sel, $_; 
}
close CMD; 
if (@sel == 0) {
	print STDERR "did not select any file\n"; 
	exit 1; 
}

open(CMD, "-|")==0 and do {
	open STDERR, ">/dev/null"; 
	exec {"nm"} "nm", @sel; 
}; 

while ($_ = getnext(\*CMD)) {
	/^Symbols/s and goto sysv; 
	/:\s*$/s and goto bsd; 
}

# probaly nm bsd type, with one arg only
@sel == 1 or die "could not parse correctly nm output"; 

if ($.) {
	# file has symbols
	push @strip, $_; 
	goto strip; 
} 

# else, do not have syms
print STDERR "no symbols have been found\n"; 
exit 1; 

sysv: 
for (;;) {
	my ($file) = /^Symbols from (.*):\s*$/s; 
	$_ = getnext(\*CMD) or die "unable to understand sysv output"; 

	## ^Name Value ... line, check and ignore
	/^Name / or die "unable to understand sysv output";
	$_ = getnext(\*CMD) or last; 

	my $pushed; 
	while (!/^Symbols from.*:\s*$/s) {
		if (!$pushed) {
			push @strip, $file;
			$pushed++; 
		}
		$_ = getnext(\*CMD) or last; 
	}
	defined $_ or last; 
}
goto strip; 

bsd: 
for (;;) {
	my ($file) = /^(.*):\s*$/s; 
	my $pushed;
	$_ = getnext(\*CMD) or last; 
	while (!/^.*:\s*$/s) {
		if (!$pushed) {
			push @strip, $file;
			$pushed++;
		}
		$_ = getnext(\*CMD) or last;
	}
	defined $_ or last; 
}

strip: 
if ($o{'dont'}) {
	$, = "\n"; 
	print @strip; @strip and print "\n"; 
} elsif (@strip) {
	$" = " "; 
	$o{'verb'} and print "executing strip @strip\n"; 
	exec {"strip"} "strip", @strip; 
	die "strip: $!"; 
} elsif ($o{'verb'}) {
	print "nothing to do: no files to strip\n"; 
}
exit; 

###
sub getnext {
	my $f = shift; 
	local $_; 
	for (;;) {
		$_ = <$f>; 
		defined $_ or return undef; 
		$_ eq "\n" and next; 
		return $_; 
	}
}
