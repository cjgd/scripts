#! /usr/bin/perl -w

# dos2unix.pl -- convert dos to unix (CRLF line ends to LF)
# $Id: dos2unix.pl,v 1.1 2000/02/18 18:38:33 cgd Exp cgd $
# Carlos Duarte, 990131/000218

# usage: ./dos2unix files...

use strict; 

sub usage {
	print <<EOM;
usage: $0 [-h] [files...]

  -h      this help
  -n      do not perform file writes
  -v      be verbose
  -f      force conversion (does not skip, but skill checks for text/bin)
EOM
	@_ and print "\n", join("\n", @_), "\n";
	exit;
}

my %o; 
O: while (defined(my $opt = shift)) {
	$opt eq "-h" and usage;
	$opt eq "-n" and do { $o{DONT}++; next O; }; 
	$opt eq "-v" and do { $o{VERB}++; next O; }; 
	$opt eq "-f" and do { $o{NOSKIP}++; next O; }; 
	##
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}

## 
sub Verb { $o{VERB} and print STDERR @_; }

if (@ARGV==0) {
	Verb "converting stdin to stdout\n"; 
	convert(\*STDOUT, \*STDIN); 
	exit; 
}

###Verb "Accepting for conversion: "; 
my @files; 
for (@ARGV) {
	-f $_ or next; 
	-T $_ or next; 
	###Verb "$_ "; 
	push @files, $_; 
}
if (!@files) {
	Verb "... no files found\n"; 
	exit; 
}
for (@files) {
	local *F; 
	open(F, $_) or do {
		warn "opening $_: $!"; 
		next; 
	}; 
	my $l = <F>; 
	if (!$o{NOSKIP} && !($l =~ /\015\012$/s)) {
		Verb "skipping $_ ...\n"; 
		goto skip_this; 
	}; 
	Verb "converting $_ ...\n"; 
	$o{DONT} or convert($_, \*F, $l); 

skip_this: 
	close(F);
}

## 
sub convert {
	my $w = shift; 
	my $r = shift; 
	## @_ will be the header

	my $rh = $r; 
	if (ref $r eq "") {
		$rh = openit($r); 
		$rh or warn "can't open $r: $!"; 
	}
	$rh or goto the_end; 

	my @a; 
	local ($_,$.); 
	push @a, @_, <$rh>;
	for (@a) { 
		s/\015\012$/\n/s; 
	}
	if (@a) {
		$a[$#a] =~ s/\032+(\s*)$/$1/s; ## get rid of ^Z
		$a[$#a] =~ s/\000+(\s*)$/$1/s; ## get rid of NULs
		unless ($a[$#a] =~ /\n$/s) {
			if ($a[$#a] eq "") {
				pop @a; 
			} else {
				$a[$#a] .= "\n"; 
			}
		}
	}

	my $wh = $w; 
	if (ref $w eq "") {
		$wh = openit(">$w"); 
		$wh or warn "can't open $w: $!"; 
	}
	$wh or goto the_end; 

	print $wh @a; 

the_end: 
	$wh and ref $w eq "" and close $wh; 
	$rh and ref $r eq "" and close $rh; 
}

sub openit {
	my $name = shift;
	local *FH;
	return open (FH, $name) ? *FH : undef;
}
