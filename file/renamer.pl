#! /usr/bin/perl

# renamer.pl -- rename files
# $Id$
# Carlos Duarte <cgd@mail.teleweb.pt>, 990115/990218

# usage: ./rename files
# rename all files given, by replacing FROM characters to TO characters

use strict; 
use constant BAD_CHARS => "#|\\!\"\$&{}[]()?'\`* <>;";

sub usage {
	print <<EOM;
usage: $0 [-v] [-n] [-m] [-f mappings] [-r reverse_script] files
  mappings: fromchars:tochars
  fromchars, tochars: c1-c2 | c

  -n       dont! do nothing (implies -v).
  -v       be verbose.
  -f mappings
	   specify mappings to use 
  -m       merge specified mappings with default mapping (else reset 
	   defaults)
  -r file  save a sh(1) script on FILE, to reverse the effects of $0 

eg: $0 -f a-z: *       deletes lower case letters from file names
    $0 -f A-Z:a-z *    converts from upper case to lower case
    $0 -f A-Za-z0-9! * deletes all, except lowers, uppers and digits
    $0 -f 0-9!a-za-z   converts all chars, except digits, into a, b, c .... 

default mapping: convert all non ascii to "." and all meta to "_"
EOM
	exit;
}

&reset_map(); 

my ($opt); 
my (@map, @mappings); 

my $action = "yes"; 
my ($merge, $verbose, $rev_script); 
O: while (defined($opt = shift)) {
	$opt eq "-m" and do { $merge   = "yes"; next O; }; 
	$opt eq "-v" and do { $verbose = "yes"; next O; }; 
	$opt eq "-n" and do { $verbose = "yes"; $action = "no"; next O; }; 
	$opt eq "-r" and do { 
		$opt =~ s///; ($opt eq "" && !defined($opt = shift)) and usage;
		$rev_script = $opt; 
		next O; 
	}; 
	$opt =~ /^-f/ && do {
		$opt =~ s/^..//; 
		$opt eq "" and $opt = shift; 
		$opt eq "" and usage; 
		push(@mappings, $opt); 
		next O; 
	}; 
	$opt eq "--" and last O;
	$opt =~ /^-/ and usage; 
	unshift(@ARGV, $opt); 
	last O; 
}
@ARGV == 0 and usage; 

&default_map() if ($merge eq "yes" || @mappings == 0); 
&parse(@mappings) or usage; 

##print @map, "\n"; exit; 

&rs_open(); 

my $fn; 
while (defined($fn = shift)) {
	$fn =~ s#/+#/#g; 
	$fn =~ s#/$##; 

	my $dir = $fn; 
	$dir = "" unless ($dir =~ s#/[^/]*$##); 
	$dir .= "/" if ($dir ne ""); 
	$fn =~ s#^.*/##; 

	my $new = join("", map($map[ord($_)], split("", $fn))); 
	if ($new eq $fn) {
		$verbose eq "yes"
		  and print "No renaming on '${dir}${fn}'\n"; 
		next; 
	}
	$verbose eq "yes" 
	  and print "Renaming from '${dir}${fn}' to '${dir}${new}'\n"; 
	rename($dir . $fn, $dir . $new) if ($action eq "yes"); 
	&rs_add("${dir}${fn}", "${dir}${new}"); 
}
&rs_close(); 

# accepts set1[:!]set2, each set may be null, ! negates the first
# 1 if ok; 0 on bad input
sub parse {
	local $_; 
	for (@_) {
		my $neg; 
		my (@from, @to); 
		my @xx; 

		@xx = /^(.*):(.*)$/ or ++$neg and
		@xx = /^(.*)!(.*)$/ or 
		return 0; 

		@from = &expand($xx[0]); 
		@to   = &expand($xx[1]); 
		@from = &negate(@from) if $neg; 

		for (@from) {
			my $x = ""; 
			$x = chr shift @to if (@to); 
			$map[$_] = $x; 
		}
	}
	return 1; 
} 

# expand into ords
sub expand {
	my ($i, $j); 
	my @ret;
	my @x = split "", shift; 
	for ($i=0; $i<@x; ) {
		if (($x[$i+1] eq "-") && ($x[$i+2] ne "")) {
			for ($j = ord($x[$i]); $j <= ord($x[$i+2]); $j++) {
				push @ret, $j; 
			}
			$i += 3; 
		} else {
			push @ret, ord($x[$i]); 
			$i++; 
		}
	}
	return @ret; 
}

sub negate {
	my @ret; 
	my @tmp; 
	my $x; 

	while (defined($x = shift)) {
		$tmp[$x] = 1; 
	}
	for ($x=0; $x<256; $x++) {
		push(@ret, $x) unless (defined($tmp[$x])); 
	}
	return @ret; 
}

sub reset_map {
	my $i; 
	for ($i=0; $i<256; $i++) { 
		$map[$i] = chr($i); 
	}
}

sub default_map {
	my ($i, $j); 
	my @non_ascii = (0, 31, 127, 255); 

	for (;;) {
		$i = shift @non_ascii; defined($i) or last; 
		$j = shift @non_ascii; defined($j) or last; 
		while ($i <= $j) {
			$map[$i] = "."; 
			$i++; 
		}
	}
	for $i (split("", BAD_CHARS)) { 
		$map[ord($i)] = "_"; 
	}
}

sub rs_open {
	$rev_script eq "" and return 0; 
	open(RS, ">$rev_script") or die "openning $rev_script, $!"; 
	return 1; 
}

sub rs_close {
	$rev_script eq "" and return 0; 
	close(RS); 
	return 1; 
}

# args: from, to --> generate mv to from
sub rs_add {
	$rev_script eq "" and return 0; 

	my $from = shift; 
	my $to = shift; 

	for my $x ($from, $to) {
		$x =~ s/'/'\\''/g; 
	}
	print RS "mv '$to' '$from'\n"; 
	return 1; 
}

